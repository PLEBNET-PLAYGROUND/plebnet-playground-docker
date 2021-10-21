![create lnd wallet image](images/PlebnetPlayground.png)
# Plebnet Playground Sandbox Docker Package
[![plebnet-playground](https://github.com/PLEBNET-PLAYGROUND/plebnet-playground-docker/actions/workflows/plebnet-playground.yml/badge.svg)](https://github.com/PLEBNET-PLAYGROUND/plebnet-playground-docker/actions/workflows/plebnet-playground.yml)

This package will setup a bitcoind, lnd, and tor daemon that will connect to the Plebnet Playground Sandbox (Signet) Chain. This allows users to use and test bitcoin and lightning technologies without the financial risk involved with running on the mainnet chain. RTL (Ride The Lightning) and ThunderHub Web UI is also include to provide a more user friendly experience. 
## Donate to Project
***
- [Crowdfund for Playground + Plebnet.wiki running costs](https://btcpay.xenon.fun/apps/477A5RjNYiRcHWZUm4di4V6DFLnx/crowdfund)
- [Direct Donation to Xenonfun](https://btcpay.xenon.fun/apps/41Cvr8bo3LgG42kmNyyDccvMzK2U/crowdfund)
## Notes
***
- Package currently on works/tested on x64 Linux (Ubuntu specifically)
- All data for containers are bind mapped into ```volumes/``` directory inside the clone repo for ease of editing them.
- Bitcoind is not using tor, simply because it takes much longer to sync the chain, and while testing this slows me down. The playground signet chain is only around 1MB at time of writing, and takes my machine ~15 seconds to be fully synced clearnet, via tor it is taking minutes.
- You will need to setup LND wallet from scratch, instructions below
- PM [@xenonfun](https://t.me/xenonfun) on Telegram to get access to the Plebnet Playground Telegram group
- All ports are completely exposed to local host, this is mostly to make it easy for end-users to tinker, and as the signet coins in the playground are worthless so there is little risk of hacking. You can modify the ```docker-compose.yaml``` should these cause conflicts.
- For Windows users you will need to use something like git bash until we make some powershell scripts to provide cleaner functionality 
## Basic Setup
***
### Clone Repo & Install Requirements
***
```
git clone https://github.com/PLEBNET-PLAYGROUND/plebnet-playground-docker --config core.autocrlf=input
cd plebnet-playground-docker
pip3 install -r requirements.txt
```

### Supported System Architectures

| Architecture      | TRIPLET build-arg |
| ----------- | ----------- |
|  Intel x64  | x86_64-linux-gnu |
|  OSX 64-bit | aarch64-linux-gnu  |
| ARM64 linux |  aarch64-linux-gnu |

### Services
| Service      | Description  |
| ----------- | ----------- |
|  bitcoind | Bitcoin Core Daemon |
|  lnd | Lightning Labs LND Daemon  |
|  tor | tor network daemon |
| rtl |  Ride The Lightning Daemon |
| thunderhub |  Thunderhub Lightning UI |
| docs |  MKDocs documentation |
| notebook |  Jupyter Notebook environment setup for lightning development |
| dashboard |  Jupyter Dashboard |
| lndg |  lndg Dashboard (available on port 8889) |

### Install and start all services (Intel x64 example)
***

```sh
TRIPLET=x86_64-linux-gnu ./install.sh   
```

### Install and start just the `bitcoind`,`lnd` services (comma separate them)
```sh
TRIPLET=x86_64-linux-gnu services=bitcoind,lnd ./install.sh   
```

### Start containers
***
```
docker-compose up -d
```

### Stop containers
***
```
docker-compose stop
```

### Full removal of Plebnet Playground (this deletes all data out of volumes directory)
***
```
./uninstall.sh
```
***

## [Make](MAKE.md) Command

### Ubuntu Linux

```
apt install make
```

### MacOS

#### Install [Homebrew](https://brew.sh)

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```
brew install make
```

## [Play](PLAY.md) Command

```
make init && play help
```
***

## Aliases
```
alias lncli='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon '

alias change-password-playground='docker exec -it playground-lnd lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon changepassword'

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

alias bos="docker run -it --rm -v $PWD/volumes/bos_datadir:/home/node/.bos:rw --network plebnet-playground-docker_default alexbosworth/balanceofsatoshis"
```
***

## Your first playground LND wallet
***

The wallet will automatically be made for you and use the default password  is ```12345678```
You can change the password with the ```change-password-playground``` alias. If you do change your password make sure to update the ```unlock.password``` file with your new password.

 
## Make your first peer with the seed node for Plebnet Playground Signet
***
- ```connect-playground```
- Now you should get some gossip about the network and be able to run something like this ```lncli describegraph | jq .nodes[] | grep "alias"``` and see a list of the various node aliases on the network
- FYI, your alias is not set in default configuration to avoid confusion, go ahead and edit your ```lnd.conf``` and make an ```alias=YourNewAliasName``` parameter and restart the container.
- Get into the telegram group and ask for some playground signet coins and go wild.

## Get some coins
Install requirements ```pip3 install -r requirements.txt```
Run the ```./getcoins.py``` script and you will get 1tBTC put into your lightning on-chain wallet.

## RTL Setup
***
- RTL will at ```http://localhost:3000```, the default password is ```password``` and it will ask you to change this on first login.

## ThunderHub Setup
***
- ThunderHub will at at ```http://localhost:3001```, the default password is ```password```. You can change that by editing the ```volumes/thub_datadir/thubConfig.yaml```. Change `masterPassword: thunderhub-$2a$12$oRzmFZSOmvYv1heHkU053uv0a1tX9MXNqmcMpZs2hQ0t8k1Onnk1a` to `masterPassword: mynewpassword`. Then restart thunderhub using alias `restart-thub`. The masterPassword entry should automatically be converted to the hashed version of the password.

## How to setup Balance of Satoshis (BOS)
***

You may install bos only **after** you have generated an lnd wallet with `create-lnd-wallet`.

```console
sudo python3 ./install_bos.py
```
If you created the bos alias above, you should be good to go

```console
bos --version
10.9.2
```

## How to setup plebnet dashboard

The interactive dashboard is an experimental visualization engine for viewing the lightning network.
If you used the `docker-compose up -d` command above, then the dashboard will run on http://localhost:8050

By default only the playground nodes are visualized. However, you can also visualize real lightning network data by placing a `describegraph.json` file in the repo's `dashboard/` directory, then restart the dashboard setting environment variable `USE_TEST_DATA=TRUE`:

```console
USE_TEST_DATA=TRUE docker-compose up dashboard
```

![Plebnet Dashboard](images/plebnet_dashboard.png)

## Additional reference material

### Links
- [Plebnet Wiki](https://plebnet.wiki)
- [Bitcoin Wiki](https://bitcoin.it)
- [Lightning Wiki](https://lightningwiki.net/index.php/Main_Page)
- [Plebnet Telegram](http://plebnet.org/)
  
### Contributors
- [Richard Safier](https://github.com/rsafier)
- [Nan Liu](https://github.com/nanliu)
- [Lamar Wilson](https://twitter.com/bigmarh)
- [@Exfrog](https://github.com/exfrog)
- [@stflowstate](https://twitter.com/Stflowstate)
- John Doe
- [@rafgxyz](https://t.me/rafgxyz)
- [@asherp](https://github.com/asherp)
- [@RandyMcMillan](https://github.com/randymcmillan)
- [@nitesh_btc](https://twitter.com/nitesh_btc)

