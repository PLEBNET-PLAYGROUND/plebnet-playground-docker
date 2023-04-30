```
make [COMMAND] [EXTRA_ARGUMENTS]	

make 
	 make all                        install and run playground and cluster
	 make help                       print help
	 make report                     print environment variables
	 make initialize                 install dependencies - ubuntu/macOS
	 make init                       initialize basic dependencies
	 make build
	 make build para=true            parallelized build
	 make install
	 make run
	                                 basic=true - services=bitcoind,lnd,docs,tor
	                                 cluster=[true || remove]
	                                 relay=[true || remove]
	                                 services=bitcoind,lnd,lndg,rtl,thunderhub,docs,tor,dashboard,notebook
	                                 nocache=true
	                                 verbose=true

	[NOSTR SERVICES]:	
	 make nostr-rs-relay              build & run a nostr relay
	 make nostr-rs-relay-build
	 make nostr-rs-relay-run

	[DEV ENVIRONMENT]:	
	 make install-cluster

	 make signin profile=gh-user     ~/GH_TOKEN.txt required from github.com
	 make build

	 make package-all
	 profile=plebnet-playground make report
	 profile=plebnet-playground make package-all
	 profile=plebnet-playground make package-lnd
	 profile=plebnet-playground make package-tor
	 profile=plebnet-playground make package-docs
	 profile=plebnet-playground make package-bitcoind

	 make install-python38-sh
	 make install-python39-sh


	[EXAMPLES]:

	make run nocache=true verbose=true

	make init && play help

## catch install commands
```
