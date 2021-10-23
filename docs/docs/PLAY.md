## PLAY COMMAND

	play                     ids
	play                     info
	play                     iftop
	play                     ifconfig
	play                     balance
	play                     top   <CONTAINER_ID>
	play                     shell <CONTAINER_ID>
	play                     start <CONTAINER_ID>
	play                     stop  <CONTAINER_ID>
	play                     lncli -n signet walletbalance

	play                     tor-iftop

	Examples:

	play bitcoin id
	play bitcoin iftop
	play bitcoin netinfo 5
	play bitcoin gettxoutsetinfo
	play bitcoin getmininginfo

	play bitcoin '<COMMAND>'
	play bitcoin 'bitcoin-cli getblockhash 1000'
	play bitcoin 'bitcoin-cli getblock $(bitcoin-cli getblockhash 0)'

	play lnd
	play lnd id
	play lnd top
	play lnd info
	play lnd ifconfig
	play lnd balance
	play lnd '<COMMAND>'

	play-lnd balance
