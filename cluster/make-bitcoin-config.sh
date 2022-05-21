declare LND_LISTEN=playground-lnd:9735
declare LND_RPCLISTEN=playground-lnd:10009
declare LND_RESTLISTEN=playground-lnd:8080
declare zmqpubrawblock=tcp://playground-bitcoind:28332
declare zmqpubrawtx=tcp://playground-bitcoind:28333
declare torsocks=playground-tor:9050
declare torcontrol=playground-tor:9051
echo "
signet=1
rpcauth=bitcoin:c8c8b9740a470454255b7a38d4f38a52\$e8530d1c739a3bb0ec6e9513290def11651afbfd2b979f38c16ec2cf76cf348a
txindex=1
server=1
dnsseed=0
[signet]
rpcbind=0.0.0.0:38332
rpcallowip=0.0.0.0/0
whitelist=0.0.0.0/0
zmqpubrawblock=tcp://0.0.0.0:28332
zmqpubrawtx=tcp://0.0.0.0:28333
zmqpubhashblock=tcp://0.0.0.0:28334
signetchallenge=512102ee856c56a5aaadd1656f849bafa4c9dacc86a2878fe546c6189185f842ae2c1851ae
addnode=104.131.10.218:38333  

"