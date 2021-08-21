#!/bin/sh
set -eo pipefail

if [[ ! -f /data/.env ]]; then
  echo ".env file not found in volume, coping to /data/.env "
  cp /usr/local/etc/.env /data/.env 
else
  echo ".env file exists, skipping."
fi

if [[ ! -f /data/thubConfig.yaml ]]; then
  echo "thubConfig.yaml file not found in volume, coping to /data/thubConfig.yaml "
  cp /usr/local/etc/thubConfig.yaml /data/thubConfig.yaml
else
  echo "thubConfig.yaml file exists, skipping."
fi

exec "$@"
