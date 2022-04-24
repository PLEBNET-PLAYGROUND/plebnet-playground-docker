
* testing c-lightning fix from jonmthomson

### 2022-04-24 17:46:25.179767: clock-in: T-1h 

### 2022-03-06 22:09:48.211358: clock-out

* trying to build clightning container
* error when running `docker compose build clightning`
```sh
#22 1.355     Error: pg_config executable not found.
```
* questions on clighthing env variables:

```yaml
 environment:
      TRIPLET: '${TRIPLET}'
      BITCOIN_RPCHOST: playground-bitcoind
      BITCOIN_RPCCONNECT: playground-bitcoind # container name for bitcoind
      BITCOIN_RPCUSER: bitcoin
      BITCOIN_RPCPASS: bitcoin # is this right?
      ALIAS: 'NewNode'
      PROXY: playground-tor
      LOG_FILE: /root/.lightning/logs.log
      TOR_SERVICE_PASSWORD: hello # is this right?
      EXPOSE_TCP: true
      LIGHTNINGD_DATA: /root/.lightning
      LIGHTNINGD_NETWORK: signet
      LIGHTNINGD_RPC_PORT: 9835
      LIGHTNINGD_PORT: 9735 # remap to 9736?
      ANNOUNCE_ADDR: playground-clnd # Is this right?
```

* merging master

### 2022-03-06 20:14:04.895074: clock-in


### 2022-02-11 17:33:57.721456: clock-out

* removing alias

### 2022-02-11 17:16:17.926726: clock-in

### 2022-02-11 10:57:03.001138: clock-out

* single quotes for ubuntu

### 2022-02-11 10:26:17.437377: clock-in: T-10m 

### 2022-02-11 01:13:07.178217: clock-out

* added check for compose command, with fallback to docker-compose

### 2022-02-11 01:08:30.447242: clock-in: T-10m 

### 2022-02-10 23:20:26.798951: clock-out

* install instructions for Compose
* switch to docker compose

### 2022-02-10 23:09:40.015116: clock-in


### 2021-12-29 20:33:38.681602: clock-out

* trying to build clightning based on cluster dockerfile
* copying xenofun's work from plebnet-playground-cluster

### 2021-12-29 19:54:38.356443: clock-in


### 2021-12-26 23:14:47.513874: clock-out

* unable to connect to bitcoin-cli
`bitcoin-cli -rpcconnect playground-bitcoind -rpcport 38332 -rpcuser bitcoin -rpcpassword bitcoin`
* running lightning container `docker compose run --entrypoint bash clightning`

### 2021-12-26 21:37:39.721294: clock-in

### 2021-12-26 20:59:49.569589: clock-out

* adding c-lighting

### 2021-12-26 19:50:09.021401: clock-in

### 2021-09-25 14:59:37.408376: clock-out

* converted to undirected graph to capture all routes
* adding dashboard to notebook container path
* May not be capturing all routes since using directed graph
* Converting from Directed Graph to Undirected Graph

### 2021-09-25 13:44:27.854547: clock-in


### 2021-09-19 23:33:00.430605: clock-out

* default omegaconf version
* requirements for plebnet_generate.py
* omegaconf
* instructions for installing specific services only
* recursively resolve dependencies
* cli for user-requested services

### 2021-09-19 21:15:56.114833: clock-in


### 2021-09-12 00:59:52.378945: clock-out: T-1h 

* running notebook server
* added notebook service

### 2021-09-11 21:01:16.312788: clock-in

### 2021-09-10 15:25:25.628446: clock-out

* image link
* dashboard instructions

### 2021-09-10 15:19:36.121187: clock-in

### 2021-09-10 15:18:52.895954: clock-out

* dashboard docs
* cosmetic changes
* merging
* working dashboard

### 2021-09-10 11:49:31.529800: clock-in

### 2021-09-09 21:56:24.416247: clock-out

* got interactive graph exploration working

### 2021-09-09 19:59:44.110560: clock-in

### 2021-09-09 19:56:35.628573: clock-out

* psidash

### 2021-09-09 19:48:36.305532: clock-in

### 2021-09-07 12:37:49.146073: clock-out

* adding psidash

### 2021-09-07 12:23:54.789958: clock-in

### 2021-09-06 20:00:08.495368: clock-out

* troubleshooting dashboard container with Richard, Randy

### 2021-09-06 19:19:55.258548: clock-in: T-1h 

### 2021-09-06 16:14:24.088591: clock-out

* refactoring to dashboard library

### 2021-09-06 15:35:37.593682: clock-in

### 2021-09-06 14:14:45.488795: clock-out

* interpolating positions from base path

### 2021-09-06 12:38:29.198835: clock-in

### 2021-09-05 22:31:50.256312: clock-out

* python 3.7 for networkx compatibility
* containerizing dashboard

### 2021-09-05 21:08:35.199569: clock-in

### 2021-09-05 13:24:24.791297: clock-out

* shortest path vis looking better

### 2021-09-05 11:31:17.028480: clock-in: T-10m 

### 2021-09-04 18:34:24.628271: clock-out

* multipath vis
* adding grpc defs

### 2021-09-04 17:06:16.103299: clock-in: T-15m 

### 2021-09-01 16:23:47.698346: clock-out

* multipath vis

### 2021-09-01 13:49:54.103872: clock-in

### 2021-08-31 22:30:33.124519: clock-out

* simple path visualization

### 2021-08-31 20:25:59.032072: clock-in

### 2021-08-30 19:41:07.202459: clock-out

* meeting with Richard/Randy
* testing docker volume permissions

### 2021-08-30 17:22:19.733165: clock-in

### 2021-08-30 16:04:33.359857: clock-out

* look at generating macaroons from command line
* firecracker vm setup?

### 2021-08-30 14:54:58.062615: clock-in

### 2021-08-29 15:19:51.728227: clock-out

* degree histogram
* looking at k-componts

### 2021-08-29 14:51:03.558541: clock-in

### 2021-08-29 14:22:39.600142: clock-out: T-1h30m 

* calculating weights for minimum spanning tree

### 2021-08-29 12:18:35.208999: clock-in

### 2021-08-29 12:18:32.450252: clock-out: T-3h 


### 2021-08-29 07:47:31.354669: clock-in

### 2021-08-28 21:53:50.692778: clock-out: T-1h 


### 2021-08-28 20:32:21.015838: clock-in

### 2021-08-28 18:49:44.214159: clock-out

* https://github.com/andrerfneves/lightning-address/blob/master/README.md

### 2021-08-28 17:56:44.676004: clock-in

### 2021-08-28 17:01:25.899171: clock-out

* trying minimum spanning tree, shortest path algorithms

### 2021-08-28 16:18:02.400093: clock-in

### 2021-08-28 11:40:17.494006: clock-out

* added colors, starting to create channels, visualized global network

### 2021-08-28 09:43:10.421124: clock-in

### 2021-08-27 22:34:51.923450: clock-out: T-15m 

* converting to undirected graph

### 2021-08-27 22:07:57.449360: clock-in

### 2021-08-27 13:21:37.244392: clock-out

* got first node/edge graph to render

### 2021-08-27 10:26:15.392487: clock-in

### 2021-08-26 21:20:12.717150: clock-out

* got describegraph in grpc to pull nodes/edges

### 2021-08-26 20:17:20.601943: clock-in

### 2021-08-26 14:06:28.635993: clock-out

* merging multi-platform install


### 2021-08-26 14:02:13.394526: clock-in


### 2021-08-26 21:49:09.898758: clock-out

* copying config.json over to volume

### 2021-08-26 21:43:18.142796: clock-in

### 2021-08-26 21:37:06.837015: clock-out

* moving bos credentials into volume
* also @apembroke you need to switch script to move those template files over into the volume, the script edited the /bos files, which is part of github repo so could get checked in

### 2021-08-26 21:21:08.568937: clock-in

### 2021-08-26 16:32:44.887667: clock-out

* updated bos alias

* getting the following error when running `bos peers`

```console
err: 
  message: 400,ExpectedLndWithKnownChain
  stack: 
    - Error: 400,ExpectedLndWithKnownChain
    -     at /app/node_modules/async/asyncify.js:105:61
    -     at processTicksAndRejections (node:internal/process/task_queues:96:5)
```

* Keeping credentials.json fixed in the repo so user updates have no effect:

```console
git update-index --assume-unchanged bos/node/credentials.json
```

To continue tracking changes, use the following:

```console
git update-index --no-assume-unchanged bos/node/credentials.json
```

* verbose output
* bos prototype install

* building install script for bos

bos instructions do not work https://github.com/alexbosworth/balanceofsatoshis
```console
!base64 volumes/lnd_datadir/tls.cert | tr -d '\n'
```

Above command does not actually strip the newline character. When I decode in python, the line is still there.


### 2021-08-26 14:06:43.311135: clock-in


### 2021-08-25 23:24:46.982492: clock-out

* mounting volumes/bos_datadir for bos container
* removing volume README.md

### 2021-08-25 22:43:15.162846: clock-in

### 2021-08-25 22:05:30.948513: clock-out

* dashboard passwords, meeting with Richard

### 2021-08-25 20:28:27.858430: clock-in

### 2021-08-25 18:21:40.161252: clock-out

* fixed up arch table
* `ARCH=aarch64-linux-gnu` works on my mac. bitcoind starts up
* docker-compose was not stopping containers on my mac, but restarting docker desktop from tray icon worked
* docker-compose up sometimes fails with tor still running: `docker system prune` resolved my issue
* ignore data volumes and any dev-dependent hourly configs
* added worklogs directory for dev time tracking
* mounting data volumes from repo

### 2021-08-25 16:37:02.531165: clock-in: T-20m 

