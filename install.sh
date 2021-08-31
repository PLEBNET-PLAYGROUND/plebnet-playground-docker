#!/usr/bin/env bash
#ENV VARS
OS=$(uname)
OS_VERSION=$(uname -r)
UNAME_M=$(uname -m)
ARCH=$(uname -m)
export OS
export OS_VERSION
export UNAME_M
export ARCH
report() {
echo OS:
echo "$OS" | awk '{print tolower($0)}'
echo OS_VERSION:
echo "$OS_VERSION" | awk '{print tolower($0)}'
echo UNAME_M:
echo "$UNAME_M" | awk '{print tolower($0)}'
echo ARCH:
echo "$ARCH" | awk '{print tolower($0)}'
echo OSTYPE:
echo "$OSTYPE" | awk '{print tolower($0)}'
}
checkbrew() {
    if hash brew 2>/dev/null; then
        if !hash $AWK 2>/dev/null; then
            brew install $AWK
        fi
        if !hash git 2>/dev/null; then
            brew install git
        fi
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        checkbrew
    fi
}
checkraspi(){
    echo 'Checking Raspi'
    if [ -e /etc/rpi-issue ]; then
    echo "- Original Installation"
    cat /etc/rpi-issue
    fi
    if [ -e /usr/bin/lsb_release ]; then
    echo "- Current OS"
    lsb_release -irdc
    fi
    echo "- Kernel"
    uname -r
    echo "- Model"
    cat /proc/device-tree/model && echo
    echo "- hostname"
    hostname
    echo "- Firmware"
    /opt/vc/bin/vcgencmd version
}

if [[ "$OSTYPE" == "linux"* ]]; then
    #CHECK APT
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        PACKAGE_MANAGER=apt
        export PACKAGE_MANAGER
        INSTALL=install
        export INSTALL
        AWK=gawk
        export AWK
        if hash apt 2>/dev/null; then
            $PACKAGE_MANAGER $INSTALL $AWK
            report
        fi
    fi
    if [[ "$OSTYPE" == "linux-musl" ]]; then
        PACKAGE_MANAGER=apk
        export PACKAGE_MANAGER
        INSTALL=add
        export INSTALL
        AWK=gawk
        export AWK
        if hash apk 2>/dev/null; then
            $PACKAGE_MANAGER $INSTALL $AWK
            report
        fi
    fi
    if [[ "$OSTYPE" == "linux-arm"* ]]; then
        PACKAGE_MANAGER=apt
        export PACKAGE_MANAGER
        INSTALL=install
        export INSTALL
        AWK=gawk
        echo $AWK
        export AWK
        checkraspi
        if hash apt 2>/dev/null; then
            $PACKAGE_MANAGER $INSTALL $AWK
            report
        fi
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
        report
        PACKAGE_MANAGER=brew
        export PACKAGE_MANAGER
        INSTALL=install
        export INSTALL
        AWK=awk
        export AWK
        checkbrew
elif [[ "$OSTYPE" == "cygwin" ]]; then
    echo TODO add support for $OSTYPE
elif [[ "$OSTYPE" == "msys" ]]; then
    echo TODO add support for $OSTYPE
elif [[ "$OSTYPE" == "win32" ]]; then
    echo TODO add support for $OSTYPE
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    echo TODO add support for $OSTYPE
else
    echo TODO add support for $OSTYPE
fi

if [ -z "$1" ]
    then
    echo 'You must provide ARCH as first parameter'
    echo './install.sh x86_64'
    exit;
fi

ARCH=$1
#Remove any old version
docker-compose down
sudo rm -rf volumes

#Create Datafile
mkdir -p volumes
mkdir -p volumes/lnd_datadir
mkdir -p volumes/bitcoin_datadir
mkdir -p volumes/thub_datadir
mkdir -p volumes/rtl_datadir
mkdir -p volumes/tor_datadir
mkdir -p volumes/tor_servicesdir
mkdir -p volumes/tor_torrcdir
docker-compose build --build-arg ARCH=$ARCH
docker-compose up -d

