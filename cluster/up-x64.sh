if [[ $# -ne 1 ]];
then
    echo "up-x64.sh (# of instances)"
    exit
fi

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

#This is for internal testing only
TRIPLET=x86_64-linux-gnu
torcount=`expr $1 / 3 + 1`
echo $torcount
python plebnet_generate.py TRIPLET=x86_64-linux-gnu bitcoind=$1 lnd=$1 tor=$torcount

#Remove
docker compose down || docker-compose down
sudo -s chown -R $(id -u) *
sudo -s rm -rf volumes

#Create Datafile
sudo -s mkdir volumes

sudo -s chown -R $(id -u) *
declare n=$1
for (( i=0; i<=n-1; i++ ))
do
    echo $i
    mkdir -p volumes/lnd_datadir_$i
    mkdir -p volumes/bitcoin_datadir_$i

#    mkdir volumes/tor_torrcdir_1
done
for (( i=0; i<=torcount; i++ ))
do
    echo $i
    mkdir -p volumes/tor_datadir_$i
    mkdir -p volumes/tor_servicesdir_$i
    mkdir -p volumes/tor_torrcdir_$i
done

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

docker compose build --parallel --build-arg TRIPLET=$TRIPLET || docker-compose build --parallel --build-arg TRIPLET=$TRIPLET
docker compose up --remove-orphans -d || docker-compose up --remove-orphans -d


