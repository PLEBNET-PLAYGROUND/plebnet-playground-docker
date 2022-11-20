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
	 make install-cluster
	                                 services=bitcoind,lnd,lndg,rtl,thunderhub,docs,tor,dashboard,notebook
	 make run
	                                 nocache=true verbose=true

	[DEV ENVIRONMENT]:	

	 make signin profile=gh-user     ~/GH_TOKEN.txt required from github.com
	 make build
	 make package-all

	 make install-python38-sh
	 make install-python39-sh


	[EXAMPLES]:

	make run nocache=true verbose=true

	make init && play help

```
