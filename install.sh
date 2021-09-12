if [ -z "$1" ]
    then
    echo 'You must provide TRIPLET as first parameter'
    echo './install.sh x86_64-linux-gnu'
    exit;
fi
PWD=$PWD
export PWD
TIME=$(date +%s)
TRIPLET=$1
#Remove any old version
docker-compose down
SOURCE=$PWD/volumes/statoshi_datadir
DEST=~/.statoshi_datadir-$TIME
./scripts/fastcopy-chaindata.py $SOURCE $DEST
sudo rm -rf volumes
./scripts/fastcopy-chaindata.py $DEST $SOURCE
#Create Datafile
mkdir volumes
mkdir volumes/lnd_datadir
mkdir volumes/bitcoin_datadir
mkdir volumes/statoshi_datadir
mkdir volumes/thub_datadir
mkdir volumes/rtl_datadir
mkdir volumes/tor_datadir
mkdir volumes/tor_servicesdir
mkdir volumes/tor_torrcdir
docker-compose build --build-arg TRIPLE=$TRIPLE
docker-compose up -d --scale statoshi=0
