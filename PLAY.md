## PLAY COMMAND
```
play ids
play images
play tor-iftop

Examples:

play-bitcoin

play bitcoin
play bitcoin id
play bitcoin iftop
play bitcoin netinfo 5
play bitcoin gettxoutsetinfo
play bitcoin getmininginfo

play bitcoin '<COMMAND>'
play bitcoin 'bitcoin-cli getblockhash 1000'
play bitcoin 'bitcoin-cli getblock $(bitcoin-cli getblockhash 0)'

play-lnd

play lnd
play lnd id
play lnd iftop
play lnd newaddress
play lnd walletbalance
play lnd total-balance
play lnd '<COMMAND>'
play lnd 'lncli'

play-lnd balance

https://www.plebnet.fun

Fund playground_lnd wallet with signet coins
play-getcoins -a $(play-lnd getnewaddress)

Fund playground_bitcoin wallet with signet coins
play-getcoins -a $(play-bitcoin getnewaddress)

Nested Commands:
play-getcoins -a $(play-bitcoin getnewaddress) &&  play-getcoins -a $(play-lnd getnewaddress)

```
## PLAY-BITCOIN COMMAND
```
play-bitcoin id
play-bitcoin top
play-bitcoin ifconfig
play-bitcoin iftop
play-bitcoin netinfo 5
play-bitcoin shell
play-bitcoin start
play-bitcoin stop

play-bitcoin '<COMMAND>'
play-bitcoin createwallet  playground-wallet
play-bitcoin createwallet  <walletname>
play-bitcoin listwallets
play-bitcoin getnewaddress playground-wallet
play-bitcoin getnewaddress <walletname>
play-bitcoin getbalance
play-bitcoin getbalances

https://www.plebnet.fun

Fund bitcoin playground-wallet:
play-getcoins -a $(play-bitcoin getnewaddress)

```
## PLAY-LND COMMAND
```
play-lnd id
play-lnd top
play-lnd ifconfig
play-lnd iftop
play-lnd shell
play-lnd start
play-lnd stop

play-lnd '<COMMAND>'
play-lnd newaddress
play-lnd walletbalance
play-lnd total-balance
play-lnd confirmed-balance
play-lnd unconfirmed-balance

https://www.plebnet.fun

Fund LND signet wallet:
play-getcoins -a $(play-lnd getnewaddress)
```
