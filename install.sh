if [ -z "$1" ]
    then
    echo "Auto Detect"
    if [ "$(uname -m)" == "arm64" ]; then
        echo "ARM Chip found"
        if [ "$(sysctl -n machdep.cpu.brand_string)" == "Apple M1" ]; then
            echo "M1 ARM detected"
            export TRIPLET="aarch64-linux-gnu"
        else
            export TRIPLET="arm64-linux-gnu"
        fi
    elif [ "$(uname -m)" == "x86_64" ]; then
        #echo 'You must provide TRIPLET as first parameter'
        #echo './install.sh x86_64-linux-gnu'
        export TRIPLET="x86_64-linux-gnu"
    fi
    # echo "EXAMPLE:"
    # echo "         TRIPLET=x86_64-linux-gnu ./install.sh"
    # echo "EXAMPLE:"
    # echo "         TRIPLET=x86_64-linux-gnu services=bitcoind,lnd ./install.sh"
    echo "TRIPLET=" $TRIPLET
    echo "services:" $services
    echo
else
    TRIPLET=$1
    : ${TRIPLET:=$TRIPLET}
    : ${services:=Null}
fi
docker compose down || docker-compose down

python3 plebnet_generate.py TRIPLET=$TRIPLET services=$services

if [ "$RESET" == "true" ]; then
    read -p "Clobber volumes directory - This will destroy private keys!!! (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -rf volumes
    fi
fi

#Create data directories
mkdir -p volumes
mkdir -p volumes/lnd_datadir
mkdir -p volumes/cln_datadir
mkdir -p volumes/bitcoin_datadir
mkdir -p volumes/thub_datadir
mkdir -p volumes/rtl_datadir
mkdir -p volumes/tor_datadir
mkdir -p volumes/tor_servicesdir
mkdir -p volumes/tor_torrcdir
mkdir -p volumes/lndg_datadir

#REF: https://docs.docker.com/engine/install/linux-postinstall
while ! docker system info > /dev/null 2>&1; do
    echo "Waiting for docker to start..."
    if [[ "$(uname -s)" == "Linux" ]]; then
        systemctl restart docker.service
    fi
    if [[ "$(uname -s)" == "Darwin" ]]; then
        open --background -a /./Applications/Docker.app/Contents/MacOS/Docker
    fi

    sleep 1;

done

docker compose build --build-arg TRIPLET=$TRIPLET || docker-compose build --build-arg TRIPLET=$TRIPLET
docker compose up --remove-orphans -d || docker-compose up --remove-orphans -d

