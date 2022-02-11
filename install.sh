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


if ! command -v docker compose &> /dev/null
then
    echo "docker compose could not be found, defaulting to docker-compose"
    alias compose_cmd="docker-compose"
else
    alias compose_cmd="docker compose"
fi

#Remove any old version
compose_cmd down

python3 plebnet_generate.py TRIPLET=$TRIPLET services=$services

if [ "$RESET" == "true" ]; then
    read -p "Clobber volumes directory - This will destroy private keys!!! (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -rf volumes
    fi
fi

#Create Datafile
mkdir -p volumes
mkdir -p volumes/lnd_datadir
mkdir -p volumes/bitcoin_datadir
mkdir -p volumes/thub_datadir
mkdir -p volumes/rtl_datadir
mkdir -p volumes/tor_datadir
mkdir -p volumes/tor_servicesdir
mkdir -p volumes/tor_torrcdir
mkdir -p volumes/lndg_datadir

compose_cmd build --build-arg TRIPLET=$TRIPLET
compose_cmd up --remove-orphans -d
