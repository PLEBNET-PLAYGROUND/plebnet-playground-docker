if [ -z "$1" ]
    then
    if [[ "$(echo uname -m)" == "arm64" ]];then
        TRIPLET="aarch64-linux-gnu"
        echo TRIPLET=$TRIPLET
    else
        #echo 'You must provide TRIPLET as first parameter'
        #echo './install.sh x86_64-linux-gnu'
        echo
    fi
    echo "EXAMPLE:"
    echo "         TRIPLET=x86_64-linux-gnu ./install.sh"
    echo "EXAMPLE:"
    echo "         TRIPLET=x86_64-linux-gnu services=bitcoind,lnd ./install.sh"
    TRIPLET=$(uname -m)-linux-gnu
    echo TRIPLET=$TRIPLET
    echo services:$services
    echo
else
TRIPLET=$1
: ${TRIPLET:=$TRIPLET}
: ${services:=Null}
fi


#Remove any old version
docker-compose down

python plebnet_generate.py TRIPLET=$TRIPLET services=$services

sudo rm -rf volumes

#Create Datafile
mkdir volumes
mkdir volumes/lnd_datadir
mkdir volumes/bitcoin_datadir
mkdir volumes/thub_datadir
mkdir volumes/rtl_datadir
mkdir volumes/tor_datadir
mkdir volumes/tor_servicesdir
mkdir volumes/tor_torrcdir
mkdir volumes/lndg_datadir
touch volumes/lndg_datadir/db.sqlite3

docker-compose build --build-arg TRIPLET=$TRIPLET
docker-compose up --remove-orphans -d
