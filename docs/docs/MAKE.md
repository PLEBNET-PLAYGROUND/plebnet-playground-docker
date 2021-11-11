## MAKE COMMAND
make[1]: Entering directory '/root/plebnet-playground-docker'

	[USAGE]: make [COMMAND] [EXTRA_ARGUMENTS]	


		 make 
		 make help                       print help
		 make report                     print environment variables
		 make initialize                 install dependencies
		 make init                       initialize basic dependencies
		 make build
		 make build para=true            parallelized build
		 make install
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
	
make[1]: Leaving directory '/root/plebnet-playground-docker'
