# Plebnet Playground Docker Package

This package will setup a bitcoind and lnd daemon that will connect to the Plebnet Playground Sandbox (Signet) Chain. This allows users to use and test bitcoin and lightning technologies without the financial risk involved with running on the mainnet chain.
## Donate to Project
- [Crowdfund for Playground + Plebnet.wiki running costs](https://btcpay.xenon.fun/apps/477A5RjNYiRcHWZUm4di4V6DFLnx/crowdfund)
- [Direct Donation to Xenonfun](https://btcpay.xenon.fun/apps/41Cvr8bo3LgG42kmNyyDccvMzK2U/crowdfund)
## Notes
- Package currently on works/tested on x64 Linux (Ubuntu specifically)
- This will also run under Windows Docker Desktop, be aware your docker volumes will be located via special share ```\\wsl$\docker-desktop-data\version-pack-data\community\docker\volumes```
- Bitcoind is not using tor, simply because it takes much longer to sync the chain, and while testing this slows me down. The playground signet chain is only around 1MB at time of writing, and takes my machine ~15 seconds to be fully synced clearnet, via tor it is taking minutes.
- You will need to setup LND wallet from scratch, instructions below
- PM @xenonfun on Telegram to get access to the Plebnet Playground Telegram group and get some playground tBTC coins to start playing with (faucet will be coming in the future)
- All ports are completely exposed to local host, this is mostly to make it easy for end-users to tinker, and as the signet coins in the playground are worthless so there is little risk of hacking. You can modify the ```docker-compose.yaml``` should these cause conflits.
- FYI if you are not running the instructions below as root or the aliases you might need to alter these with ```sudo```
## Basic Setup

### Clone Repo
```
git clone https://github.com/PLEBNET-PLAYGROUND/plebnet-playground-docker --config core.autocrlf=input
cd plebnet-playground-docker
```
### Install and start containers
```
docker-compose up --no-start --build
docker start playground-tor
docker start playground-bitcoind
docker start playground-lnd
```
### Setup bash aliases for your convenience
```
alias lncli='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon '

alias create-lnd-wallet='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon create'

alias unlock-lnd='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon unlock'

alias connect-playground='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon connect 03ee9d906caa8e8e66fe97d7a76c2bd9806813b0b0f1cee8b9d03904b538f53c4e@104.131.10.218:9735'

alias logs-bitcoind='docker logs playground-bitcoind'

alias logs-lnd='docker logs playground-lnd'

alias logs-tor='docker logs playground-tor'

alias restart-lnd='docker restart playground-lnd'

```
### Create your first playground LND wallet
```
create-lnd-wallet
```
![create lnd wallet image](/images/create-wallet.png)

### Modify your lnd.conf to auto unlock your wallet in future
- Create a password file like ```unlock.password``` in your lnd docker volume (On my machine this happens to be ```/var/lib/docker/volumes/plebnet-playground-docker_lnd_datadir/_data/```), the only content of this file will be your plaintext password you used to generate your wallet in prior step. 
- Edit ```lnd.conf``` file and add ```wallet-unlock-password-file=/root/.lnd/unlock.password``` parameter configuration pointing to the LND container relative path to you created in prior step.
- ```docker restart playground-lnd``` and your lnd container should now automaticly unlock your wallet on startup

### Make your first peer with the seed node for Plebnet Playground Signet
- ```connect-playground```
- Now you should get some gossip about the network and be able to run something like this ```lncli describegraph | jq .nodes[] | grep "alias"``` and see a list of the various node aliases on the network
- FYI, your alias is not set in default configuration to avoid confusion, go ahead and edit your ```lnd.conf``` and make an ```alias=YourNewAliasName``` parameter and restart the container.
- Get into the telegram group and ask for some playground signet coins and go wild.

### Additional reference material
- [Plebnet Wiki](https://plebnet.wiki)
- [Bitcoin Wiki](https://bitcoin.it)
- [Lightning Wiki](https://lightningwiki.net/index.php/Main_Page)
- [Plebnet Telegram](http://plebnet.org/)
  
### Contributors to project
- Richard Safier
- Nan Liu