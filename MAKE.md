## MAKE COMMAND

	[USAGE]: make [COMMAND] [EXTRA_ARGUMENTS]	


		 make 
		 make help                       print help
		 make report                     print environment variables
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


	[EXAMPLES]:

		make run nocache=true verbose=true

		make init && play help
	
