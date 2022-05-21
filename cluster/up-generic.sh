#This is for internal testing only
if [ -z "$1" ]; then
    $1=5
fi
: ${TRIPLET:=x86_64-linux-gnu}
: ${bitcoind=$1}
: ${lnd=$1}
: ${tor=$1}

python plebnet_generate.py TRIPLET=$TRIPLET bitcoind=$bitcoind lnd=$lnd tor=$tor

#Remove
docker-compose down

#Create Datafile
mkdir -p volumes

for (( i=0; i<=$bitcoind-1; i++ ))
do
    mkdir -p volumes/bitcoin_datadir_$i
done
for (( i=0; i<=$lnd-1; i++ ))
do
    mkdir -p volumes/lnd_datadir_$i
done
for (( i=0; i<=$tor-1; i++ ))
do
    mkdir -p volumes/tor_datadir_$i
    mkdir -p volumes/tor_servicesdir_$i
    mkdir -p volumes/tor_torrcdir_$i
done

docker-compose build --build-arg TRIPLET=$TRIPLET
docker-compose up --remove-orphans -d

