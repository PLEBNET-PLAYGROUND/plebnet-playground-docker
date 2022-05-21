docker-compose stop
dirs=$(ls -d backup/*)
for f in $dirs
do
    num=$(echo $f | tr -d 'backup/')
    echo $num 
    sudo rm -v ./volumes/lnd_datadir_${num}/lnd.conf
    sudo cp -v ./backup/${num}/config/* ./volumes/lnd_datadir_${num}/
    sudo cp -v ./backup/${num}/chain/* ./volumes/lnd_datadir_${num}/data/chain/bitcoin/signet/
    sudo cp -v ./backup/${num}/graph/* ./volumes/lnd_datadir_${num}/data/graph/signet/
done
docker-compose start