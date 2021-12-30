#!/bin/bash 
set -eo pipefail

initial_config_file()
{
 echo "bitcoin-rpcconnect=${BITCOIN_RPCCONNECT}
bitcoin-rpcuser=${BITCOIN_RPCUSER}
bitcoin-rpcpassword=${BITCOIN_RPCPASSWORD}
alias=${ALIAS}
proxy=${PROXY}
log-file=${LOG_FILE}
tor-service-password=${TOR_SERVICE_PASSWORD}" > /root/.lightning/signet/config
} 

 mkdir -p /root/.lightning/signet/



if [[ ! -f /root/.lightning/signet/config ]]; then
  echo "signet/config file not found in volume, building."
  initial_config_file
else
  echo "signet/config file exists, skipping."
fi

networkdatadir="${LIGHTNINGD_DATA}/${LIGHTNINGD_NETWORK}"
 
exec $@
 