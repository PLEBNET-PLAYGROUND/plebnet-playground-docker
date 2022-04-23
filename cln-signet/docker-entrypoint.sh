#!/bin/bash 
set -eo pipefail

initial_config_file()
{
  echo "alias=${CLN_ALIAS}
network=signet
bitcoin-rpcconnect=${BITCOIN_RPC_HOST}
bitcoin-rpcuser=bitcoin
bitcoin-rpcpassword=bitcoin
bitcoin-rpcport=38332
proxy=${TOR_PROXY}
bind-addr=127.0.0.1:${LIGHTNINGD_PORT}
addr=statictor:${TOR_ADDR}/torport=${LIGHTNINGD_PORT}
tor-service-password=hello" >> /root/.lightning/config    
}


if [[ ! -f /root/.lightning/config ]]; then
  echo "/root/.lightning/config not found in volume, building."
  initial_config_file
else 
    echo "/root/.lightning/config exists, skipping."
fi

if [[ "$@" = "lightningd" ]]; then
  exec lightningd
else
  exec "$@"
fi
