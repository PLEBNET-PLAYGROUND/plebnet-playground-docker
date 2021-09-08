add_unlock_to_conf()
{
  echo "12345678" > /root/.lnd/unlock.password
  echo "wallet-unlock-password-file=/root/.lnd/unlock.password" >> /root/.lnd/lnd.conf
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
 