# Plebnet Playground Docker Package

This package will setup a bitcoind and lnd daemon that will connect to the Plebnet Playground Sandbox (Signet) Chain. This allows users to use and test bitcoin and lightning technologies without the financial risk involved with running on the mainnet chain.

## Notes
- Package currently on works/tested on x64 Linux (Ubuntu specifically)
- Bitcoind is not using tor, simply because it takes much longer to sync the chain, and while testing this slows me down. The playground signet chain is only around 1MB at time of writing, and takes my machine ~15 seconds to be fully synced clearnet, via tor it is taking minutes.
- You will need to setup LND wallet from scratch, instructions below
- PM @xenonfun on Telegram to get access to the Plebnet Playground Telegram group and get some playground tBTC coins to start playing with (faucet will be coming in the future)

## Basic Setup

### Install and start containers
```
docker-compose up --no-start --build
docker start playground-tor
docker start playground-bitcoind
docker start playground-lnd
```
### Setup aliases for your convenience
```
alias lncli='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon '

alias create-lnd-wallet='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/admin.macaroon create'

alias unlock-lnd='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon unlock'

alias connect-playground='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon connect 03ee9d906caa8e8e66fe97d7a76c2bd9806813b0b0f1cee8b9d03904b538f53c4e@104.131.10.218:9735'

alias logs-bitcoind='docker logs playground-bitcoind'

alias logs-lnd='docker logs playground-lnd'

alias logs-tor='docker logs playground-tor'

```
### Create your first playground LND wallet
```
create-lnd-wallet
```
![create lnd wallet image](/images/create-wallet.png)

### Modify your lnd.conf to auto unlock your wallet in future
- Create a password file like ```unlock.password``` in your lnd docker volume (On my machine this happens to be ```/var/lib/docker/volumes/plebnet-playground-docker_lnd_datadir/_data/```), the only content of this file will be your plaintext password you used to generate your wallet in prior step. 
- 
- Edit ```lnd.conf``` file and add ```wallet-unlock-password-file=/root/.lnd/unlock.password``` parameter configuration pointing to the LND container relative path to you created in prior step.
- ``docker restart playground-lnd``` and your lnd container should now automaticly unlock your wallet on startup

### Make your first peer with the seed node for Plebnet Playground Signet
- ```connect-playground```
- Now you should get some gossip about the network and be able to run something like this ```lncli describegraph | jq .nodes[] | grep "alias"``` and see a list of the various node aliases on the network
- FYI, your alias is not set in default configuration to avoid confusion, go ahead and edit your ```lnd.conf``` and make an ```alias=YourNewAliasName``` parameter and restart the container.
- Get into the telegram group and ask for some playground signet coins and go wild.

### Additional reference material
- [Plebnet Wiki](https://plebnet.wiki)
- [Plebnet Telegram](http://plebnet.org/)
  
