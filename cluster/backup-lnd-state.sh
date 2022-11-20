docker-compose stop
dirs=$(ls -d volumes/lnd*)
for f in $dirs
do
    num=$(echo $f | tr -d 'volumes/lnd_datadir_')
    echo $num
    mkdir -p ./backup/${num}/chain
    mkdir -p ./backup/${num}/graph
    mkdir -p ./backup/${num}/config
    sudo cp -v ${f}/* ./backup/${num}/config 
    sudo cp -v ${f}/data/chain/bitcoin/signet/* ./backup/${num}/chain
    sudo cp -v ${f}/data/graph/signet/* ./backup/${num}/graph
    sudo rm -v ./backup/${num}/config/lnd.conf #remove this because it will cause issues on restore
done