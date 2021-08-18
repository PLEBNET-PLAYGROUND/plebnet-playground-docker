#!/bin/bash
set -eo pipefail

if [[ ! -f /root/.lnd/lnd.conf ]]; then
  echo "lnd.conf file not found in volume, coping to /root/.lnd/lnd.conf"
  cp /usr/local/etc/lnd.conf /root/.lnd/lnd.conf
else
  echo "lnd.conf file exists, skipping."
fi

exec "$@"
