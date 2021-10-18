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