#!/usr/bin/env bash
docker-compose down
pushd cluster && docker-compose down && popd
mkdir -p volumes
mkdir -p cluster/volumes
uninstall (){

# default is to do nothing
read -p "This will destroy private keys! Continue? (y/n) " -n 1;
echo "	";
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -rf volumes;
    sudo rm -rf cluster/volumes;
else
    read -p "Create a backup of the volumes folder? Continue? (y/n) " -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "	";
        TIME=$(date +%s)
        BAK=volumes-$TIME
        CLUSTER_BAK=cluster/volumes-$TIME
        mv volumes ./$BAK
        mv cluster/volumes $CLUSTER_BAK
        echo $BAK created...
        echo $CLUSTER_BAK created...
        ls -ld volumes-*
        ls -ld cluster/volumes-*
    else
        exit 0;
    fi
fi
}
uninstall