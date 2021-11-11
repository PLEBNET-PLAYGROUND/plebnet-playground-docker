## PLAY COMMAND

	play                     ids
	play                     top
	play                     shell
	play                     start
	play                     stop
	play                     iftop
	play                     ifconfig
	play                     newaddress
	play                     total-balance
	play                     confirmed-balance
	play                     unconfirmed-balance
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
	play lnd newaddress
	play lnd total-balance
	play lnd '<COMMAND>'

	play-lnd balance
