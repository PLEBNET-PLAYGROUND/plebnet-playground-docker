if [ -z "$1" ]
    then 
    echo 'You must provide ARCH as first parameter'
    echo './install.sh x86_64-linux-gnu'
    exit;
fi

ARCH=$1
#Remove any old version
docker-compose down 
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
docker-compose build --build-arg ARCH=($ARCH)
docker-compose up -d
