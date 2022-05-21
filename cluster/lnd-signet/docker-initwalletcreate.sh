 
echo "[lnd_unlock] Waiting 2 seconds for lnd..."
sleep 2

LND_DIR=/root/.lnd

echo "waiting for wallet create phase"
while
    if grep -q 'lncli create' $LND_DIR/logs/bitcoin/signet/lnd.log;
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

curl -X GET --cacert $LND_DIR/tls.cert https://localhost:8080/v1/genseed | jq .cipher_seed_mnemonic | tr -d '\n'| tr -d ' ' > $LND_DIR/seeds.txt
 # { 
 #   "cipher_seed_mnemonic": <array string>, 
 #   "enciphered_seed": <byte>, 
 # }
 # cat seeds.txt | jq .cipher_seed_mnemonic | tr -d '\n'
#password is 12345678
postdata='{"wallet_password":"MTIzNDU2Nzg=","cipher_seed_mnemonic":'
postdata+=$(cat $LND_DIR/seeds.txt)
postdata+='}'

curl -X POST --cacert $LND_DIR/tls.cert -s https://localhost:8080/v1/initwallet -d $postdata

echo "12345678" > /root/.lnd/unlock.password
echo "wallet-unlock-password-file=/root/.lnd/unlock.password" >> /root/.lnd/lnd.conf

 
# ensure that lnd is up and running before proceeding
while
    CA_CERT="/root/.lnd/tls.cert"
    LND_WALLET_DIR="/root/.lnd/data/chain/bitcoin/signet/"
    MACAROON_HEADER="Grpc-Metadata-macaroon: $(xxd -p  -c 1000 /root/.lnd/data/chain/bitcoin/signet/admin.macaroon |  tr '[:lower:]' '[:upper:]')"
    echo $MACAROON_HEADER
    STATUS_CODE=$(curl -s --cacert "$CA_CERT" -H "$MACAROON_HEADER" -o /dev/null -w "%{http_code}" https://localhost:8080/v1/getinfo)
    # if lnd is running it'll either return 200 if unlocked (noseedbackup=1) or 404 if it needs initialization/unlock
    if [ "$STATUS_CODE" == "200" ] || [ "$STATUS_CODE" == "404" ] ; then
        PUBKEY=$(curl -X GET --cacert "$CA_CERT" -s --header "$MACAROON_HEADER" https://localhost:8080/v1/getinfo | jq .identity_pubkey | tr -d '"')
        echo "Public Key: ${PUBKEY}"
        echo "alias=${n}-${PUBKEY:0:16}" >> /root/.lnd/lnd.conf
        break
    else    
        echo "[lnd_unlock] LND still didn't start, got $STATUS_CODE status code back... waiting another 2 seconds..."
        sleep 2
    fi
do true; done

echo "Restarting to grab new alias."
reboot   
