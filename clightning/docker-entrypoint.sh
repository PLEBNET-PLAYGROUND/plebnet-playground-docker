#!/bin/bash 
set -eo pipefail

: "${EXPOSE_TCP:=true}"

networkdatadir="${LIGHTNINGD_DATA}/${LIGHTNINGD_NETWORK}"

if [[ ! -s  ${LIGHTNINGD_DATA}/config ]]; then
    echo "Write default config file !!!"
    echo "
network=signet
bind-addr=0.0.0.0:9735
bitcoin-rpcconnect=${BITCOIN_RPCHOST}
bitcoin-rpcuser=${BITCOIN_RPCUSER}
bitcoin-rpcpassword=${BITCOIN_RPCPASS}
bitcoin-rpcport=38332
large-channels
experimental-websocket-port=8080
experimental-onion-messages
experimental-offers
fetchinvoice-noconnect
experimental-shutdown-wrong-funding
experimental-dual-fund
autocleaninvoice-cycle=6000
autocleaninvoice-expired-by=6000
alias=${ALIAS}
proxy=${PROXY}
log-file=${LOG_FILE}
tor-service-password=${TOR_SERVICE_PASSWORD}" > ${LIGHTNINGD_DATA}/config

    if [[ ! -z "${ANNOUNCE_ADDR}" ]]; then
        echo "announce-addr=${ANNOUNCE_ADDR}:9735" >> ${LIGHTNINGD_DATA}/config
    fi
else 
    echo "Nothing to write config already exists!"
fi

if [ "$EXPOSE_TCP" == "true" ]; then
    set -m
    lightningd --network="${LIGHTNINGD_NETWORK}" "$@" &

    echo "C-Lightning starting"
    while read -r i; do if [ "$i" = "lightning-rpc" ]; then break; fi; done \
    < <(inotifywait -e create,open --format '%f' --quiet "${networkdatadir}" --monitor)
    echo "C-Lightning started"
    echo "C-Lightning started, RPC available on port $LIGHTNINGD_RPC_PORT"

    socat "TCP4-listen:$LIGHTNINGD_RPC_PORT,fork,reuseaddr" "UNIX-CONNECT:${networkdatadir}/lightning-rpc" &
    fg %-
else
    exec lightningd --network="${LIGHTNINGD_NETWORK}" "$@"
fi