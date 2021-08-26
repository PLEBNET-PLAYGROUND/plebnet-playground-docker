#This is for internal testing only

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
docker-compose build --build-arg ARCH=x86_64-linux-gnu
docker-compose up -d
