#!/bin/sh

mkdir -p "$(dirname $TOR_CONFIG)"

mkdir -p "$TOR_DATA"
chown -R tor "$TOR_DATA"
chmod 700 "$TOR_DATA"

mkdir -p "/var/lib/tor/hidden_services"
chown -R tor /var/lib/tor/hidden_services
chmod 700 /var/lib/tor/hidden_services

if [[ ! -f $TOR_CONFIG ]]; then
	echo "$TOR_CONFIG file not found in volume."
	cp /torrc $TOR_CONFIG  
else
	echo "$TOR_CONFIG file exists, skipping."
fi

chown -R tor "$(dirname $TOR_CONFIG)"

exec gosu tor "$@"