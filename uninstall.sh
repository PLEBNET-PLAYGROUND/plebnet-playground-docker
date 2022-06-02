#!/usr/bin/env bash
docker-compose down
mkdir -p volumes
uninstall (){

# default is to do nothing
read -p "This will destroy private keys! Continue? (y/n) " -n 1;
echo "	";
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -rf volumes;
else
    read -p "Create a backup of the volumes folder? Continue? (y/n) " -n 1;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "	";
        TIME=$(date +%s)
        BAK=volumes-$TIME
        mv volumes ./$BAK
        echo $BAK created...
        ls -ld volumes-*
    else
        exit 0;
    fi
fi
}
uninstall