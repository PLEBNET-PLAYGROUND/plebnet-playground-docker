//! Server process
use crate::close::Close;
use crate::close::CloseCmd;
use crate::config::{Settings, VerifiedUsersMode};
use crate::conn;
use crate::db;
use crate::db::SubmittedEvent;
use crate::error::{Error, Result};
use crate::event::Event;
use crate::event::EventCmd;
use crate::info::RelayInfo;
use crate::nip05;
use crate::notice::Notice;
use crate::subscription::Subscription;
use futures::SinkExt;
use futures::StreamExt;
use governor::{Jitter, Quota, RateLimiter};
use http::header::HeaderMap;
use hyper::header::ACCEPT;
use hyper::service::{make_service_fn, service_fn};
use hyper::upgrade::Upgraded;
use hyper::{
    header, server::conn::AddrStream, upgrade, Body, Request, Response, Server, StatusCode,
};
use rusqlite::OpenFlags;
use serde::{Deserialize, Serialize};
use serde_json::json;
use std::collections::HashMap;
use std::convert::Infallible;
use std::net::SocketAddr;
use std::path::Path;
use std::sync::atomic::Ordering;
use std::sync::mpsc::Receiver as MpscReceiver;
use std::time::Duration;
use std::time::Instant;
use tokio::runtime::Builder;
use tokio::sync::broadcast::{self, Receiver, Sender};
use tokio::sync::mpsc;
use tokio::sync::oneshot;
use tokio_tungstenite::WebSocketStream;
use tracing::*;
use tungstenite::error::CapacityError::MessageTooLong;
use tungstenite::error::Error as WsError;
use tungstenite::handshake;
use tungstenite::protocol::Message;
use tungstenite::protocol::WebSocketConfig;

/// Handle arbitrary HTTP requests, including for WebSocket upgrades.
async fn handle_web_request(
    mut request: Request<Body>,
    pool: db::SqlitePool,
    settings: Settings,
    remote_addr: SocketAddr,
    broadcast: Sender<Event>,
    event_tx: tokio::sync::mpsc::Sender<SubmittedEvent>,
    shutdown: Receiver<()>,
) -> Result<Response<Body>, Infallible> {
    match (
        request.uri().path(),
        request.headers().contains_key(header::UPGRADE),
    ) {
        // Request for / as websocket
        ("/", true) => {
            trace!("websocket with upgrade request");
            //assume request is a handshake, so create the handshake response
            let response = match handshake::server::create_response_with_body(&request, || {
                Body::empty()
            }) {
                Ok(response) => {
                    //in case the handshake response creation succeeds,
                    //spawn a task to handle the websocket connection
                    tokio::spawn(async move {
                        //using the hyper feature of upgrading a connection
                        match upgrade::on(&mut request).await {
                            //if successfully upgraded
                            Ok(upgraded) => {
                                // set WebSocket configuration options
                                let config = WebSocketConfig {
                                    max_message_size: settings.limits.max_ws_message_bytes,
                                    max_frame_size: settings.limits.max_ws_frame_bytes,
                                    ..Default::default()
                                };
                                //create a websocket stream from the upgraded object
                                let ws_stream = WebSocketStream::from_raw_socket(
                                    //pass the upgraded object
                                    //as the base layer stream of the Websocket
                                    upgraded,
                                    tokio_tungstenite::tungstenite::protocol::Role::Server,
                                    Some(config),
                                )
                                .await;
                                let origin = get_header_string("origin", request.headers());
                                let user_agent = get_header_string("user-agent", request.headers());
                                // determine the remote IP from headers if the exist
                                let header_ip = settings
                                    .network
                                    .remote_ip_header
                                    .as_ref()
                                    .and_then(|x| get_header_string(x, request.headers()));
                                // use the socket addr as a backup
                                let remote_ip =
                                    header_ip.unwrap_or_else(|| remote_addr.ip().to_string());
                                let client_info = ClientInfo {
                                    remote_ip,
                                    user_agent,
                                    origin,
                                };
                                // spawn a nostr server with our websocket
                                tokio::spawn(nostr_server(
                                    pool,
                                    client_info,
                                    settings,
                                    ws_stream,
                                    broadcast,
                                    event_tx,
                                    shutdown,
                                ));
                            }
                            // todo: trace, don't print...
                            Err(e) => println!(
                                "error when trying to upgrade connection \
                                 from address {} to websocket connection. \
                                 Error is: {}",
                                remote_addr, e
                            ),
                        }
                    });
                    //return the response to the handshake request
                    response
                }
                Err(error) => {
                    warn!("websocket response failed");
                    let mut res =
                        Response::new(Body::from(format!("Failed to create websocket: {}", error)));
                    *res.status_mut() = StatusCode::BAD_REQUEST;
                    return Ok(res);
                }
            };
            Ok::<_, Infallible>(response)
        }
        // Request for Relay info
        ("/", false) => {
            // handle request at root with no upgrade header
            // Check if this is a nostr server info request
            let accept_header = &request.headers().get(ACCEPT);
            // check if application/nostr+json is included
            if let Some(media_types) = accept_header {
                if let Ok(mt_str) = media_types.to_str() {
                    if mt_str.contains("application/nostr+json") {
                        // build a relay info response
                        debug!("Responding to server info request");
                        let rinfo = RelayInfo::from(settings.info);
                        let b = Body::from(serde_json::to_string_pretty(&rinfo).unwrap());
                        return Ok(Response::builder()
                            .status(200)
                            .header("Content-Type", "application/nostr+json")
                            .header("Access-Control-Allow-Origin", "*")
                            .body(b)
                            .unwrap());
                    }
                }
            }
            Ok(Response::builder()
                .status(200)
                .header("Content-Type", "text/plain")
                .body(Body::from("Please use a Nostr client to connect."))
                .unwrap())
        }
        (_, _) => {
            //handle any other url
            Ok(Response::builder()
                .status(StatusCode::NOT_FOUND)
                .body(Body::from("Nothing here."))
                .unwrap())
        }
    }
}

fn get_header_string(header: &str, headers: &HeaderMap) -> Option<String> {
    headers
        .get(header)
        .and_then(|x| x.to_str().ok().map(|x| x.to_string()))
}

// return on a control-c or internally requested shutdown signal
async fn ctrl_c_or_signal(mut shutdown_signal: Receiver<()>) {
    let mut term_signal = tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())
        .expect("could not define signal");
    loop {
        tokio::select! {
            _ = shutdown_signal.recv() => {
            info!("Shutting down webserver as requested");
                    // server shutting down, exit loop
                    break;
                },
            _ = tokio::signal::ctrl_c() => {
            info!("Shutting down webserver due to SIGINT");
                    break;
            },
        _ = term_signal.recv() => {
        info!("Shutting down webserver due to SIGTERM");
        break;
        },
        }
    }
}

/// Start running a Nostr relay server.
pub fn start_server(settings: Settings, shutdown_rx: MpscReceiver<()>) -> Result<(), Error> {
    trace!("Config: {:?}", settings);
    // do some config validation.
    if !Path::new(&settings.database.data_directory).is_dir() {
        error!("Database directory does not exist");
        return Err(Error::DatabaseDirError);
    }
    let addr = format!(
        "{}:{}",
        settings.network.address.trim(),
        settings.network.port
    );
    let socket_addr = addr.parse().expect("listening address not valid");
    // address whitelisting settings
    if let Some(addr_whitelist) = &settings.authorization.pubkey_whitelist {
        info!(
            "Event publishing restricted to {} pubkey(s)",
            addr_whitelist.len()
        );
    }
    // check if NIP-05 enforced user verification is on
    if settings.verified_users.is_active() {
        info!(
            "NIP-05 user verification mode:{:?}",
            settings.verified_users.mode
        );
        if let Some(d) = settings.verified_users.verify_update_duration() {
            info!("NIP-05 check user verification every:   {:?}", d);
        }
        if let Some(d) = settings.verified_users.verify_expiration_duration() {
            info!("NIP-05 user verification expires after: {:?}", d);
        }
        if let Some(wl) = &settings.verified_users.domain_whitelist {
            info!("NIP-05 domain whitelist: {:?}", wl);
        }
        if let Some(bl) = &settings.verified_users.domain_blacklist {
            info!("NIP-05 domain blacklist: {:?}", bl);
        }
    }
    // configure tokio runtime
    let rt = Builder::new_multi_thread()
        .enable_all()
        .thread_name_fn(|| {
	    // give each thread a unique numeric name
	    static ATOMIC_ID: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
	    let id = ATOMIC_ID.fetch_add(1,Ordering::SeqCst);
	    format!("tokio-ws-{}", id)
		})
        // limit concurrent SQLite blocking threads
        .max_blocking_threads(settings.limits.max_blocking_threads)
        .on_thread_start(|| {
            trace!("started new thread: {:?}", std::thread::current().name());
        })
        .on_thread_stop(|| {
	    trace!("stopped thread: {:?}", std::thread::current().name());
        })
        .build()
        .unwrap();
    // start tokio
    rt.block_on(async {
        let broadcast_buffer_limit = settings.limits.broadcast_buffer;
        let persist_buffer_limit = settings.limits.event_persist_buffer;
        let verified_users_active = settings.verified_users.is_active();
        let db_min_conn = settings.database.min_conn;
        let db_max_conn = settings.database.max_conn;
        let settings = settings.clone();
        info!("listening on: {}", socket_addr);
        // all client-submitted valid events are broadcast to every
        // other client on this channel.  This should be large enough
        // to accomodate slower readers (messages are dropped if
        // clients can not keep up).
        let (bcast_tx, _) = broadcast::channel::<Event>(broadcast_buffer_limit);
        // validated events that need to be persisted are sent to the
        // database on via this channel.
        let (event_tx, event_rx) = mpsc::channel::<SubmittedEvent>(persist_buffer_limit);
        // establish a channel for letting all threads now about a
        // requested server shutdown.
        let (invoke_shutdown, shutdown_listen) = broadcast::channel::<()>(1);
        // create a channel for sending any new metadata event.  These
        // will get processed relatively slowly (a potentially
        // multi-second blocking HTTP call) on a single thread, so we
        // buffer requests on the channel.  No harm in dropping events
        // here, since we are protecting against DoS.  This can make
        // it difficult to setup initial metadata in bulk, since
        // overwhelming this will drop events and won't register
        // metadata events.
        let (metadata_tx, metadata_rx) = broadcast::channel::<Event>(4096);
        // start the database writer thread.  Give it a channel for
        // writing events, and for publishing events that have been
        // written (to all connected clients).
        db::db_writer(
            settings.clone(),
            event_rx,
            bcast_tx.clone(),
            metadata_tx.clone(),
            shutdown_listen,
        )
        .await;
        info!("db writer created");

        // create a nip-05 verifier thread; if enabled.
        if settings.verified_users.mode != VerifiedUsersMode::Disabled {
            let verifier_opt =
                nip05::Verifier::new(metadata_rx, bcast_tx.clone(), settings.clone());
            if let Ok(mut v) = verifier_opt {
                if verified_users_active {
                    tokio::task::spawn(async move {
                        info!("starting up NIP-05 verifier...");
                        v.run().await;
                    });
                }
            }
        }
        // build a connection pool for DB maintenance
        let maintenance_pool = db::build_pool(
            "maintenance writer",
            &settings,
            OpenFlags::SQLITE_OPEN_READ_WRITE | OpenFlags::SQLITE_OPEN_CREATE,
            1,
            2,
            false,
        );
        db::db_optimize(maintenance_pool.clone()).await;
        db::db_checkpoint(maintenance_pool).await;

        // listen for (external to tokio) shutdown request
        let controlled_shutdown = invoke_shutdown.clone();
        tokio::spawn(async move {
            info!("control message listener started");
            match shutdown_rx.recv() {
                Ok(()) => {
                    info!("control message requesting shutdown");
                    controlled_shutdown.send(()).ok();
                }
                Err(std::sync::mpsc::RecvError) => {
                    // FIXME: spurious error on startup?
                    debug!("shutdown requestor is disconnected");
                }
            };
        });
        // listen for ctrl-c interruupts
        let ctrl_c_shutdown = invoke_shutdown.clone();
        // listener for webserver shutdown
        let webserver_shutdown_listen = invoke_shutdown.subscribe();

        tokio::spawn(async move {
            tokio::signal::ctrl_c().await.unwrap();
            info!("shutting down due to SIGINT (main)");
            ctrl_c_shutdown.send(()).ok();
        });
        // build a connection pool for sqlite connections
        let pool = db::build_pool(
            "client query",
            &settings,
            rusqlite::OpenFlags::SQLITE_OPEN_READ_ONLY,
            db_min_conn,
            db_max_conn,
            true,
        );
	// spawn a task to check the pool size.
	let pool_monitor = pool.clone();
	tokio::spawn(async move {db::monitor_pool("reader", pool_monitor).await;});

        // A `Service` is needed for every connection, so this
        // creates one from our `handle_request` function.
        let make_svc = make_service_fn(|conn: &AddrStream| {
            let svc_pool = pool.clone();
            let remote_addr = conn.remote_addr();
            let bcast = bcast_tx.clone();
            let event = event_tx.clone();
            let stop = invoke_shutdown.clone();
            let settings = settings.clone();
            async move {
                // service_fn converts our function into a `Service`
                Ok::<_, Infallible>(service_fn(move |request: Request<Body>| {
                    handle_web_request(
                        request,
                        svc_pool.clone(),
                        settings.clone(),
                        remote_addr,
                        bcast.clone(),
                        event.clone(),
                        stop.subscribe(),
                    )
                }))
            }
        });
        let server = Server::bind(&socket_addr)
            .serve(make_svc)
            .with_graceful_shutdown(ctrl_c_or_signal(webserver_shutdown_listen));
        // run hyper in this thread.  This is why the thread does not return.
        if let Err(e) = server.await {
            eprintln!("server error: {}", e);
        }
    });
    Ok(())
}

/// Nostr protocol messages from a client
#[derive(Deserialize, Serialize, Clone, PartialEq, Eq, Debug)]
#[serde(untagged)]
pub enum NostrMessage {
    /// An `EVENT` message
    EventMsg(EventCmd),
    /// A `REQ` message
    SubMsg(Subscription),
    /// A `CLOSE` message
    CloseMsg(CloseCmd),
}

/// Convert Message to NostrMessage
fn convert_to_msg(msg: String, max_bytes: Option<usize>) -> Result<NostrMessage> {
    let parsed_res: Result<NostrMessage> = serde_json::from_str(&msg).map_err(|e| e.into());
    match parsed_res {
        Ok(m) => {
            if let NostrMessage::EventMsg(_) = m {
                if let Some(max_size) = max_bytes {
                    // check length, ensure that some max size is set.
                    if msg.len() > max_size && max_size > 0 {
                        return Err(Error::EventMaxLengthError(msg.len()));
                    }
                }
            }
            Ok(m)
        }
        Err(e) => {
            debug!("proto parse error: {:?}", e);
            debug!("parse error on message: {}", msg.trim());
            Err(Error::ProtoParseError)
        }
    }
}

/// Turn a string into a NOTICE message ready to send over a WebSocket
fn make_notice_message(notice: Notice) -> Message {
    let json = match notice {
        Notice::Message(ref msg) => json!(["NOTICE", msg]),
        Notice::EventResult(ref res) => json!(["OK", res.id, res.status.to_bool(), res.msg]),
    };

    Message::text(json.to_string())
}

struct ClientInfo {
    remote_ip: String,
    user_agent: Option<String>,
    origin: Option<String>,
}

/// Handle new client connections.  This runs through an event loop
/// for all client communication.
async fn nostr_server(
    pool: db::SqlitePool,
    client_info: ClientInfo,
    settings: Settings,
    mut ws_stream: WebSocketStream<Upgraded>,
    broadcast: Sender<Event>,
    event_tx: mpsc::Sender<SubmittedEvent>,
    mut shutdown: Receiver<()>,
) {
    // the time this websocket nostr server started
    let orig_start = Instant::now();
    // get a broadcast channel for clients to communicate on
    let mut bcast_rx = broadcast.subscribe();
    // Track internal client state
    let mut conn = conn::ClientConn::new(client_info.remote_ip);
    // subscription creation rate limiting
    let mut sub_lim_opt = None;
    // 100ms jitter when the rate limiter returns
    let jitter = Jitter::up_to(Duration::from_millis(100));
    let sub_per_min_setting = settings.limits.subscriptions_per_min;
    if let Some(sub_per_min) = sub_per_min_setting {
        if sub_per_min > 0 {
            trace!("Rate limits for sub creation ({}/min)", sub_per_min);
            let quota_time = core::num::NonZeroU32::new(sub_per_min).unwrap();
            let quota = Quota::per_minute(quota_time);
            sub_lim_opt = Some(RateLimiter::direct(quota));
        }
    }
    // Use the remote IP as the client identifier
    let cid = conn.get_client_prefix();
    // Create a channel for receiving query results from the database.
    // we will send out the tx handle to any query we generate.
    // this has capacity for some of the larger requests we see, which
    // should allow the DB thread to release the handle earlier.
    let (query_tx, mut query_rx) = mpsc::channel::<db::QueryResult>(20000);
    // Create channel for receiving NOTICEs
    let (notice_tx, mut notice_rx) = mpsc::channel::<Notice>(128);

    // last time this client sent data (message, ping, etc.)
    let mut last_message_time = Instant::now();

    // ping interval (every 5 minutes)
    let default_ping_dur = Duration::from_secs(settings.network.ping_interval_seconds.into());

    // disconnect after 20 minutes without a ping response or event.
    let max_quiet_time = Duration::from_secs(60 * 20);

    let start = tokio::time::Instant::now() + default_ping_dur;
    let mut ping_interval = tokio::time::interval_at(start, default_ping_dur);

    // maintain a hashmap of a oneshot channel for active subscriptions.
    // when these subscriptions are cancelled, make a message
    // available to the executing query so it knows to stop.
    let mut running_queries: HashMap<String, oneshot::Sender<()>> = HashMap::new();
    // for stats, keep track of how many events the client published,
    // and how many it received from queries.
    let mut client_published_event_count: usize = 0;
    let mut client_received_event_count: usize = 0;
    debug!("new client connection (cid: {}, ip: {:?})", cid, conn.ip());
    let origin = client_info.origin.unwrap_or_else(|| "<unspecified>".into());
    let user_agent = client_info
        .user_agent
        .unwrap_or_else(|| "<unspecified>".into());
    debug!(
        "cid: {}, origin: {:?}, user-agent: {:?}",
        cid, origin, user_agent
    );
    loop {
        tokio::select! {
            _ = shutdown.recv() => {
        info!("Close connection down due to shutdown, client: {}, ip: {:?}, connected: {:?}", cid, conn.ip(), orig_start.elapsed());
                // server shutting down, exit loop
                break;
            },
            _ = ping_interval.tick() => {
                // check how long since we talked to client
                // if it has been too long, disconnect
                if last_message_time.elapsed() > max_quiet_time {
                    debug!("ending connection due to lack of client ping response");
                    break;
                }
                // Send a ping
                ws_stream.send(Message::Ping(Vec::new())).await.ok();
            },
            Some(notice_msg) = notice_rx.recv() => {
                ws_stream.send(make_notice_message(notice_msg)).await.ok();
            },
            Some(query_result) = query_rx.recv() => {
                // database informed us of a query result we asked for
                let subesc = query_result.sub_id.replace('"', "");
                if query_result.event == "EOSE" {
                    let send_str = format!("[\"EOSE\",\"{}\"]", subesc);
                    ws_stream.send(Message::Text(send_str)).await.ok();
                } else {
                    client_received_event_count += 1;
                    // send a result
                    let send_str = format!("[\"EVENT\",\"{}\",{}]", subesc, &query_result.event);
                    ws_stream.send(Message::Text(send_str)).await.ok();
                }
            },
            // TODO: consider logging the LaggedRecv error
            Ok(global_event) = bcast_rx.recv() => {
                // an event has been broadcast to all clients
                // first check if there is a subscription for this event.
                for (s, sub) in conn.subscriptions() {
                    if !sub.interested_in_event(&global_event) {
                        continue;
                    }

                    // TODO: serialize at broadcast time, instead of
                    // once for each consumer.
                    if let Ok(event_str) = serde_json::to_string(&global_event) {
                        trace!("sub match for client: {}, sub: {:?}, event: {:?}",
                               cid, s,
                               global_event.get_event_id_prefix());
                        // create an event response and send it
                        let subesc = s.replace('"', "");
                        ws_stream.send(Message::Text(format!("[\"EVENT\",\"{}\",{}]", subesc, event_str))).await.ok();
                    } else {
                        warn!("could not serialize event: {:?}", global_event.get_event_id_prefix());
                    }
                }
            },
            ws_next = ws_stream.next() => {
                // update most recent message time for client
                last_message_time = Instant::now();
                // Consume text messages from the client, parse into Nostr messages.
                let nostr_msg = match ws_next {
                    Some(Ok(Message::Text(m))) => {
                        convert_to_msg(m,settings.limits.max_event_bytes)
                    },
            Some(Ok(Message::Binary(_))) => {
            ws_stream.send(
                make_notice_message(Notice::message("binary messages are not accepted".into()))).await.ok();
                        continue;
                    },
                    Some(Ok(Message::Ping(_) | Message::Pong(_))) => {
                        // get a ping/pong, ignore.  tungstenite will
                        // send responses automatically.
                        continue;
                    },
            Some(Err(WsError::Capacity(MessageTooLong{size, max_size}))) => {
            ws_stream.send(
                make_notice_message(Notice::message(format!("message too large ({} > {})",size, max_size)))).await.ok();
                        continue;
            },
                    None |
            Some(Ok(Message::Close(_)) |
             Err(WsError::AlreadyClosed | WsError::ConnectionClosed |
                 WsError::Protocol(tungstenite::error::ProtocolError::ResetWithoutClosingHandshake)))
                        => {
                            debug!("websocket close from client (cid: {}, ip: {:?})",cid, conn.ip());
                        break;
                    },
                    Some(Err(WsError::Io(e))) => {
                        // IO errors are considered fatal
                        warn!("IO error (cid: {}, ip: {:?}): {:?}", cid, conn.ip(), e);
                        break;
                    }
                    x => {
                        // default condition on error is to close the client connection
                        info!("unknown error (cid: {}, ip: {:?}): {:?} (closing conn)", cid, conn.ip(), x);
                        break;
                    }
                };

                // convert ws_next into proto_next
                match nostr_msg {
                    Ok(NostrMessage::EventMsg(ec)) => {
                        // An EventCmd needs to be validated to be converted into an Event
                        // handle each type of message
                        let evid = ec.event_id().to_owned();
                        let parsed : Result<Event> = Result::<Event>::from(ec);
                        match parsed {
                            Ok(e) => {
                                let id_prefix:String = e.id.chars().take(8).collect();
                                debug!("successfully parsed/validated event: {:?} (cid: {})", id_prefix, cid);
                                // check if the event is too far in the future.
                                if e.is_valid_timestamp(settings.options.reject_future_seconds) {
                                    // Write this to the database.
                                    let submit_event = SubmittedEvent { event: e.clone(), notice_tx: notice_tx.clone() };
                                    event_tx.send(submit_event).await.ok();
                                    client_published_event_count += 1;
                } else {
                    info!("client: {} sent a far future-dated event", cid);
                    if let Some(fut_sec) = settings.options.reject_future_seconds {
                        let msg = format!("The event created_at field is out of the acceptable range (+{}sec) for this relay.",fut_sec);
                        let notice = Notice::invalid(e.id, &msg);
                        ws_stream.send(make_notice_message(notice)).await.ok();
                    }
                }
                            },
                            Err(e) => {
                                info!("client sent an invalid event (cid: {})", cid);
                                ws_stream.send(make_notice_message(Notice::invalid(evid, &format!("{}", e)))).await.ok();
                            }
                        }
                    },
                    Ok(NostrMessage::SubMsg(s)) => {
                        debug!("subscription requested (cid: {}, sub: {:?})", cid, s.id);
                        // subscription handling consists of:
                        // * check for rate limits
                        // * registering the subscription so future events can be matched
                        // * making a channel to cancel to request later
                        // * sending a request for a SQL query
            // Do nothing if the sub already exists.
            if !conn.has_subscription(&s) {
                if let Some(ref lim) = sub_lim_opt {
                lim.until_ready_with_jitter(jitter).await;
                }
                            let (abandon_query_tx, abandon_query_rx) = oneshot::channel::<()>();
                            match conn.subscribe(s.clone()) {
                Ok(()) => {
                                    // when we insert, if there was a previous query running with the same name, cancel it.
                                    if let Some(previous_query) = running_queries.insert(s.id.to_owned(), abandon_query_tx) {
                    previous_query.send(()).ok();
                                    }
		                    if s.needs_historical_events() {
                                    // start a database query.  this spawns a blocking database query on a worker thread.
					db::db_query(s, cid.to_owned(), pool.clone(), query_tx.clone(), abandon_query_rx).await;
				    }
                },
                Err(e) => {
                    info!("Subscription error: {} (cid: {}, sub: {:?})", e, cid, s.id);
                                    ws_stream.send(make_notice_message(Notice::message(format!("Subscription error: {}", e)))).await.ok();
                }
                            }
            } else {
        info!("client sent duplicate subscription, ignoring (cid: {}, sub: {:?})", cid, s.id);
        }
                    },
                    Ok(NostrMessage::CloseMsg(cc)) => {
                        // closing a request simply removes the subscription.
                        let parsed : Result<Close> = Result::<Close>::from(cc);
            if let Ok(c) = parsed {
                                // check if a query is currently
                                // running, and remove it if so.
                                let stop_tx = running_queries.remove(&c.id);
                                if let Some(tx) = stop_tx {
                                    tx.send(()).ok();
                                }
                                // stop checking new events against
                                // the subscription
                                conn.unsubscribe(&c);
                            } else {
                                info!("invalid command ignored");
                                ws_stream.send(make_notice_message(Notice::message("could not parse command".into()))).await.ok();
                            }
                    },
                    Err(Error::ConnError) => {
                        debug!("got connection close/error, disconnecting cid: {}, ip: {:?}",cid, conn.ip());
                        break;
                    }
                    Err(Error::EventMaxLengthError(s)) => {
                        info!("client sent event larger ({} bytes) than max size (cid: {})", s, cid);
                        ws_stream.send(make_notice_message(Notice::message("event exceeded max size".into()))).await.ok();
                    },
                    Err(Error::ProtoParseError) => {
                        info!("client sent event that could not be parsed (cid: {})", cid);
                        ws_stream.send(make_notice_message(Notice::message("could not parse command".into()))).await.ok();
                    },
                    Err(e) => {
                        info!("got non-fatal error from client (cid: {}, error: {:?}", cid, e);
                    },
                }
            },
        }
    }
    // connection cleanup - ensure any still running queries are terminated.
    for (_, stop_tx) in running_queries {
        stop_tx.send(()).ok();
    }
    info!(
        "stopping client connection (cid: {}, ip: {:?}, sent: {} events, recv: {} events, connected: {:?})",
        cid,
        conn.ip(),
        client_published_event_count,
        client_received_event_count,
	orig_start.elapsed()
    );
}
