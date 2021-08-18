#!/bin/bash
set -eo pipefail

mkdir -p "${BITCOIN_DATA}"
mkdir -p "${BITCOIN_DIR}"
ln -sfn "${BITCOIN_DATA}" "${BITCOIN_DIR}"
   
if [[ ! -f "${BITCOIN_DIR}/bitcoin.conf" ]]; then
  echo "bitcoin.conf file not found in volume, copying to ${BITCOIN_DIR}/bitcoin.conf"
  cp /usr/local/etc/bitcoin.conf "${BITCOIN_DIR}/bitcoin.conf"
else
  echo "bitcoin.conf file exists, skipping."
fi
    
exec "$@"
