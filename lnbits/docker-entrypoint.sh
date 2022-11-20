#!/bin/sh
#set -eo pipefail

if [ ! -f /data/.env ]; then
  echo ".env file not found in volume, coping to /data/.env "
  cp /usr/local/etc/.env /data/.env 
else
  echo ".env file exists, skipping."
fi

if [ ! -f /data/lnbitsConfig.yaml ]; then
  echo "lnbitsConfig.yaml file not found in volume, coping to /data/lnbitsConfig.yaml "
  cp /usr/local/etc/lnbitsConfig.yaml /data/lnbitsConfig.yaml
else
  echo "lnbitsConfig.yaml file exists, skipping."
fi

export PGPASSWORD=myPassword
psql -h playground-postgres -U postgres -c "create database lnbits;"

exec "$@"
