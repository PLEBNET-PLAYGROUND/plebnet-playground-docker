#!/bin/bash
set -eo pipefail

initial_lnd_file()
{
  echo "
    listen=${LND_LISTEN}
    rpclisten=${LND_RPCLISTEN}
    rpclisten=127.0.0.1:10009
    restlisten=${LND_RESTLISTEN}
    restlisten=127.0.0.1:8080
    minchansize=100000
    ignore-historical-gossip-filters=true
    accept-keysend=true
    accept-amp=true
    allow-circular-route=true
    numgraphsyncpeers=3
    alias=${LND_ALIAS}
    tlsextradomain=${tlsextradomain}
    bitcoin.active=true
    bitcoin.mainnet=false
    bitcoin.signet=true
    bitcoin.signetseednode=104.131.10.218
    bitcoin.node=bitcoind
    bitcoin.dnsseed=0
    bitcoind.dir=/var/lib/bitcoind/
    bitcoind.rpchost=${rpchost}
    bitcoind.rpcuser=bitcoin
    bitcoind.rpcpass=bitcoin
    bitcoind.zmqpubrawblock=${zmqpubrawblock}
    bitcoind.zmqpubrawtx=${zmqpubrawtx}
    tor.active=true
    tor.socks=${torsocks}
    tor.control=${torcontrol}
    tor.password=hello
    tor.v3=true
    tor.skip-proxy-for-clearnet-targets=true
    protocol.wumbo-channels=true
    " >> /root/.lnd/lnd.conf
}



if [[ ! -f /root/.lnd/lnd.conf ]]; then
  echo "lnd.conf file not found in volume, building."
  initial_lnd_file
  /usr/local/etc/docker-initwalletcreate.sh &
else
  echo "lnd.conf file exists, skipping."
fi

localhostip=$(hostname -i)
if [[ -f /root/.lnd/localhostip ]]; then
  savedip=$(cat /root/.lnd/localhostip)
  if [[ $savedip != $localhostip ]]; then
    echo "IP Address changed from ${savedip} to ${localhostip}, cleaning up TLS certs"
    #ip changed lets cleanup tls stuff
    rm -f /root/.lnd/tls.key
    rm -f /root/.lnd/tls.cert
  fi
fi
echo $localhostip > /root/.lnd/localhostip

if [[ "$@" = "lnd" ]]; then
  exec lnd "--tor.targetipaddress=${localhostip}"
else
  exec "$@"
fi