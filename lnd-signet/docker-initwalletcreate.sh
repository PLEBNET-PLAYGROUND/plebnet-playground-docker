add_unlock_to_conf()
{
  echo "12345678" > /root/.lnd/unlock.password
  echo "wallet-unlock-password-file=/root/.lnd/unlock.password" >> /root/.lnd/lnd.conf
}

wait_for_lnd_startup()
{
# ensure that lnd is up and running before proceeding
while
    CA_CERT="/root/.lnd/tls.cert"
    LND_WALLET_DIR="/root/.lnd/data/chain/bitcoin/signet/"
    MACAROON_FILE="$LND_WALLET_DIR/admin.macaroon"
    MACAROON_HEADER="r0ckstar:dev"
    if [ -f "$MACAROON_FILE" ]; then
        MACAROON_HEADER="Grpc-Metadata-macaroon:$(xxd -p -c 10000 "$MACAROON_FILE" | tr -d ' ' | tr '[:lower:]' '[:upper:]')"
    fi

    STATUS_CODE=$(curl -s --cacert /root/.lnd/tls.cert -H $MACAROON_HEADER -o /dev/null -w "%{http_code}" http://localhost:8080/v1/getinfo)
    # if lnd is running it'll either return 200 if unlocked (noseedbackup=1) or 404 if it needs initialization/unlock
    if [ "$STATUS_CODE" == "200" ] || [ "$STATUS_CODE" == "404" ] ; then
        break
    else    
        echo "[lnd_unlock] LND still didn't start, got $STATUS_CODE status code back... waiting another 2 seconds..."
        sleep 2
    fi
do true; done
}

get_1_tbtc()
{
    ADDRESS=$(lncli --macaroonpath /root/.lnd/data/chain/bitcoin/signet/admin.macaroon newaddress p2wkh | jq .address | tr -d '"')
    curl http://signet.xenon.fun:5000/faucet?address=$ADDRESS
}

echo "[lnd_unlock] Waiting 2 seconds for lnd..."
sleep 2

echo "waiting for wallet create phase"
while
    if grep -q 'lncli create' /root/.lnd/logs/bitcoin/signet/lnd.log;
    then
        echo "ready to create...."
        #Need to run the python gRPC HERE
        break;
    else
        sleep 2;
        echo "waiting to create."
    fi
do true; done

#once we get here we will want to change lnd.conf with wallet-unlock-file stuff

curl -X GET --cacert /root/.lnd/tls.cert https://localhost:8080/v1/genseed | jq .cipher_seed_mnemonic | tr -d '\n'| tr -d ' ' > /root/.lnd/seeds.txt
 # { 
 #   "cipher_seed_mnemonic": <array string>, 
 #   "enciphered_seed": <byte>, 
 # }
 # cat seeds.txt | jq .cipher_seed_mnemonic | tr -d '\n'
#password is 12345678
postdata='{"wallet_password":"MTIzNDU2Nzg=","cipher_seed_mnemonic":'
postdata+=$(cat /root/.lnd/seeds.txt)
postdata+='}'
curl -X POST --cacert /root/.lnd/tls.cert https://localhost:8080/v1/initwallet -d $postdata

add_unlock_to_conf 

if [ "$GET_COINS_ON_STARTUP" = true ] ; then
    wait_for_lnd_startup
    get_1_tbtc
fi

