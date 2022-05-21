#!/bin/bash
set -eo pipefail
# ensure that lnd is up and running before proceeding
while
    CA_CERT="/root/.lnd/tls.cert"
    LND_WALLET_DIR="/root/.lnd/data/chain/bitcoin/signet/"
    MACAROON_HEADER="Grpc-Metadata-macaroon: $(xxd -p  -c 1000 /root/.lnd/data/chain/bitcoin/signet/admin.macaroon |  tr '[:lower:]' '[:upper:]')"
    echo $MACAROON_HEADER
    STATUS_CODE=$(curl -s --cacert "$CA_CERT" -H "$MACAROON_HEADER" -o state.json -w "%{http_code}" https://localhost:8080/v1/state)
    if [ "$STATUS_CODE" == "200" ]; then
        if cat state.json | grep -q RPC_ACTIVE ; then
            PUBKEY=$(curl -X GET --cacert "$CA_CERT" -s --header "$MACAROON_HEADER" https://localhost:8080/v1/getinfo | jq .identity_pubkey | tr -d '"')
            echo "Public Key: ${PUBKEY}"
            echo "alias=${n}-${PUBKEY:0:16}" >> /root/.lnd/lnd.conf
            break
        fi
    else    
        echo "[lnd_unlock] LND still didn't start, got $STATUS_CODE status code back... waiting another 2 seconds..."
        sleep 2
    fi
do true; done
echo "Restarting to grab new alias."
reboot 