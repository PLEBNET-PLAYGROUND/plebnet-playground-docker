declare LND_LISTEN=playground-lnd:9735
declare LND_RPCLISTEN=playground-lnd:10009
declare LND_RESTLISTEN=playground-lnd:8080
declare zmqpubrawblock=tcp://playground-bitcoind:28332
declare zmqpubrawtx=tcp://playground-bitcoind:28333
declare torsocks=playground-tor:9050
declare torcontrol=playground-tor:9051
echo "
[Application Options]
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
[Bitcoin]
bitcoin.active=true
bitcoin.mainnet=false
bitcoin.signet=true
bitcoin.signetseednode=104.131.10.218
bitcoin.node=bitcoind
bitcoin.dnsseed=0
[Bitcoind]
bitcoind.dir=/var/lib/bitcoind/
bitcoind.rpchost=playground-bitcoind
bitcoind.rpcuser=bitcoin
bitcoind.rpcpass=bitcoin
bitcoind.zmqpubrawblock=${zmqpubrawblock}
bitcoind.zmqpubrawtx=${zmqpubrawtx}
[tor]
tor.active=true
tor.socks=${torsocks}
tor.control=${torcontrol}
tor.password=hello
tor.v3=true
[protocol]
protocol.wumbo-channels=true
"