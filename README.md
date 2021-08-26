![create lnd wallet image](/images/PlebnetPlayground.png)
# Plebnet Playground Sandbox Docker Package
This package will setup a bitcoind, lnd, and tor daemon that will connect to the Plebnet Playground Sandbox (Signet) Chain. This allows users to use and test bitcoin and lightning technologies without the financial risk involved with running on the mainnet chain. RTL (Ride The Lightning) and ThunderHub Web UI is also include to provide a more user friendly experience. 
## Donate to Project
***
- [Crowdfund for Playground + Plebnet.wiki running costs](https://btcpay.xenon.fun/apps/477A5RjNYiRcHWZUm4di4V6DFLnx/crowdfund)
- [Direct Donation to Xenonfun](https://btcpay.xenon.fun/apps/41Cvr8bo3LgG42kmNyyDccvMzK2U/crowdfund)
## Notes
***
- Package currently on works/tested on x64 Linux (Ubuntu specifically)
- This will also run under Windows Docker Desktop, be aware your docker volumes will be located via special share ```\\wsl$\docker-desktop-data\version-pack-data\community\docker\volumes```
- On Mac getting to volumes is a bit hacky you can try to get VM that runs docker and has volume access with ```docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i bash```
- Bitcoind is not using tor, simply because it takes much longer to sync the chain, and while testing this slows me down. The playground signet chain is only around 1MB at time of writing, and takes my machine ~15 seconds to be fully synced clearnet, via tor it is taking minutes.
- You will need to setup LND wallet from scratch, instructions below
- PM @xenonfun on Telegram to get access to the Plebnet Playground Telegram group and get some playground tBTC coins to start playing with (faucet will be coming in the future)
- All ports are completely exposed to local host, this is mostly to make it easy for end-users to tinker, and as the signet coins in the playground are worthless so there is little risk of hacking. You can modify the ```docker-compose.yaml``` should these cause conflicts.
## Basic Setup
***
### Clone Repo
***
```
git clone https://github.com/PLEBNET-PLAYGROUND/plebnet-playground-docker --config core.autocrlf=input
cd plebnet-playground-docker
```
### Architectures (ARCH build-arg)
- x86_64-linux-gnu = Intel x64
- osx64 = OSX 64-bit
- arm-linux-gnueabihf = arm 32-bit linux
- aarch64-linux-gnu = ARM64 linux
### Install and start containers (Intel x64 example)
***
```
docker-compose build --build-arg ARCH=x86_64-linux-gnu
docker-compose up -d
```
### Stop containers
***
```
docker-compose stop
```
### Start containers
***
```
docker-compose up -d
```
### Full removal of Plebnet Playground (this deletes all volumes)
***
```
docker-compose down -v
```
### Setup bash aliases for your convenience
***
```
alias lncli='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon '

alias create-lnd-wallet='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon create'

alias unlock-lnd='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon unlock'

alias connect-playground='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon connect 03ee9d906caa8e8e66fe97d7a76c2bd9806813b0b0f1cee8b9d03904b538f53c4e@104.131.10.218:9735'

alias logs-bitcoind='docker logs playground-bitcoind'

alias logs-lnd='docker logs playground-lnd'

alias logs-tor='docker logs playground-tor'

alias logs-rtl='docker logs playground-rtl'

alias logs-thub='docker logs playground-thub'

alias restart-bitcoind='docker restart playground-bitcoind'

alias restart-lnd='docker restart playground-lnd'

alias restart-tor='docker restart playground-tor'

alias restart-rtl='docker restart playground-rtl'

alias restart-thub='docker restart playground-thub'

```
### Create your first playground LND wallet
***
```
create-lnd-wallet
```
![create lnd wallet image](/images/create-wallet.png)

### Modify your lnd.conf to auto unlock your wallet in future
***
- Create a password file like ```unlock.password``` in your lnd docker volume (Default location on Ubuntu is ```/var/lib/docker/volumes/plebnet-playground-docker_lnd_datadir/_data/```), the only content of this file will be your plaintext password you used to generate your wallet in prior step. 
- Edit ```lnd.conf``` file and add ```wallet-unlock-password-file=/root/.lnd/unlock.password``` parameter configuration pointing to the LND container relative path to you created in prior step.
- ```docker restart playground-lnd``` and your lnd container should now automatically unlock your wallet on startup

### Make your first peer with the seed node for Plebnet Playground Signet
***
- ```connect-playground```
- Now you should get some gossip about the network and be able to run something like this ```lncli describegraph | jq .nodes[] | grep "alias"``` and see a list of the various node aliases on the network
- FYI, your alias is not set in default configuration to avoid confusion, go ahead and edit your ```lnd.conf``` and make an ```alias=YourNewAliasName``` parameter and restart the container.
- Get into the telegram group and ask for some playground signet coins and go wild.
### Get some coins
Install requirements ```pip3 install -r requirements.txt```
Run the ```./getcoins.py``` script and you will get 1tBTC put into your lightning on-chain wallet.
## GUI Setup
****
Start GUI containers
```
docker start playground-thub
docker start playground-rtl
```
### RTL Setup
***
- RTL will at ```http://localhost:3000```, the default password is ```password``` and it will ask you to change this on first login.
### ThunderHub Setup
***
- ThunderHub will at at ```http://localhost:3001```, the default password is ```password```. You can change that by editing the ```thubConfig.yaml``` in the volume associated with ThunderHub (Default location on Ubuntu is ```/var/lib/docker/volumes/plebnet-playground-docker_thub_datadir/_data```)

### How to setup Balance of Satoshis (BOS)
***
#### Setup ```~/.bos directory``` with template from your cloned repo
```
cp -r bos/* ~/.bos
```
#### Base64 encode your ```tls.cert``` and ```admin.macaroon``` and replace values in ```credentials.json```
#### Setup Alias
```
alias bos='docker run -it --rm -v $HOME/.bos:/home/node/.bos:rw --network plebnet-playground-docker_default alexbosworth/balanceofsatoshis'
```

### Additional reference material
- [Plebnet Wiki](https://plebnet.wiki)
- [Bitcoin Wiki](https://bitcoin.it)
- [Lightning Wiki](https://lightningwiki.net/index.php/Main_Page)
- [Plebnet Telegram](http://plebnet.org/)
  
### Thanks to the contributors to project development & testing
- [Richard Safier](https://github.com/rsafier)
- [Nan Liu](https://github.com/nanliu)
- Lamar Wilson
- [@Exfrog](https://github.com/exfrog)
- @stflowstate
- John Doe
- @rafgxyz
- [@asherp](https://github.com/asherp)
- [@RandyMcMillian](https://github.com/randymcmillan)
- @nitesh_btc
