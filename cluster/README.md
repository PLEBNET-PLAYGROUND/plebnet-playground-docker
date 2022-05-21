![create lnd wallet image](/images/PlebnetPlayground.png)
# Plebnet Playground Sandbox Automated Cluster Docker Package
This package will setup a set of bitcoind, lnd, and tor docker containers so someone can spin up many nodes in order to help simulate natural traffic thru the playground network. 


On linux (for 3 nodes:
```console
pip3 install -r requirements.txt
./up-x64.sh 3
```

The `up-generic.sh` allows these to be set indpendently:

```console
pip3 install -r requirements.txt
TRIPLET=aarch64-linux-gnu bitcoind=1 lnd=1 tor=1 ./up-generic.sh
```

These services are linked in a round-robin fashion:

* `bitcoind-i` is linked to `tor-{i%tor_nodes}` for i in ``bitcoind_nodes`
* `lnd-j` is linked to `bitcoind-{j%bitcoind_nodes}` and `tor-{j%tor_nodes}` for `j` in `lnd_nodes`

If you're looking to just run a client node with GUI please visit [Plebnet Playground Docker](https://github.com/PLEBNET-PLAYGROUND/plebnet-playground-docker)
## Donate to Project
***
- [Crowdfund for Playground + Plebnet.wiki running costs](https://btcpay.xenon.fun/apps/477A5RjNYiRcHWZUm4di4V6DFLnx/crowdfund)
- [Direct Donation to Xenonfun](https://btcpay.xenon.fun/apps/41Cvr8bo3LgG42kmNyyDccvMzK2U/crowdfund)
## Notes
***
- Still pretty rough, but will automatically make wallet and unlock, seeds are in ```seeds.txt``` the password is ```12345678``` for all wallets.
- Next step is building some scripts to fill up the nodes with some Playground tBTC, establish channels, and define automatic behavior  
### Thanks to the contributors to this project development & testing
- [Richard Safier](https://github.com/rsafier)
- [@asherp](https://github.com/asherp) 
