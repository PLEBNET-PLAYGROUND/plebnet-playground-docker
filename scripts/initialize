#!/usr/bin/env bash
#ENV VARS
OS=$(uname)
OS_VERSION=$(uname -r)
UNAME_M=$(uname -m)
ARCH=$(uname -m)
AWK=$(which awk)
GAWK=$(which gawk)
export OS
export OS_VERSION
export UNAME_M
export ARCH
export AWK
export GAWK

if [[ ! -z "$GAWK" ]]; then
    AWK=$(which gawk)
    export AWK
    echo $AWK
fi

export PATH=$PATH:/usr/local/opt/python@${python_version_major}.${python_version_minor}/Frameworks/Python.framework/Versions/${python_version_major}.${python_version_minor}/bin

report() {
echo OS:
echo "$OS" | "$AWK" '{print tolower($0)}'
echo OS_VERSION:
echo "$OS_VERSION" | "$AWK" '{print tolower($0)}'
echo UNAME_M:
echo "$UNAME_M" | "$AWK" '{print tolower($0)}'
echo ARCH:
echo "$ARCH" | "$AWK" '{print tolower($0)}'
echo OSTYPE:
echo "$OSTYPE" | "$AWK" '{print tolower($0)}'
}

checkbrew() {

arch_name="$(uname -m)"

if [ "${arch_name}" = "x86_64" ]; then
    if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
        echo "Running on Rosetta 2"
    else
        echo "Running on native Intel"
    fi
elif [ "${arch_name}" = "arm64" ]; then
    echo "Running on arm64"
elif [ "${arch_name}" = "aarch64" ]; then
    echo "Running on aarch64"
else
    echo "Unknown architecture: ${arch_name}"
fi

if hash apt-get 2>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y runc containerd
    sudo apt-get install -y \
    python3 python3-pip mkdocs \
    jq runc containerd docker.io docker-compose \
        mkdocs
    if ! hash pip3 2>/dev/null; then
	sudo apt-get install python3-pip
    else
        pip3 install omegaconf glom
    fi
exit
fi

if hash brew 2>/dev/null; then
    if ! hash gawk 2>/dev/null; then
        brew install gawk
    fi
    #brew install python@3.8
    if ! hash docker 2>/dev/null; then
        brew install --cask docker
        brew install docker
        brew link docker
    fi
    if ! hash docker-compose 2>/dev/null; then
        brew install docker-compose
    fi
    if ! hash mkdocs 2>/dev/null; then
        brew install mkdocs
    fi
    if ! hash jq 2>/dev/null; then
        brew install jq
    fi
    brew install --quiet  --force python@3.9
    curl -O https://bootstrap.pypa.io/get-pip.py
    sudo -H python3 get-pip.py --no-warn-script-location

    if [ -f "/usr/local/opt/python@3.9/bin/python3" ] && [ -f "/opt/homebrew/opt/python@3.9/bin/python3" ]; then
        python39=/opt/homebrew/opt/python@3.9/bin/python3
    else
        python39=$(which python3)
    fi
    export python39
    $python39 -m pip -q install --upgrade pip
    $python39 -m pip -q install omegaconf
    echo
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
        if hash apt 2>/dev/null; then
            sudo apt install "$AWK"
            sudo apt update
            sudo apt install software-properties-common
            sudo apt install python3
            sudo apt-get install python3-pip
            sudo apt install runc containerd docker.io docker-compose

            report
            echo 'Using apt...'
        fi
    fi
    if [[ "$OSTYPE" == "linux-musl" ]]; then
        if hash apk 2>/dev/null; then
            apk add "$AWK"
            report
            echo 'Using apk...'
            apk add python3 py3-pip
            python3 -m pip install -r requirements.txt || \
            python3 -m pip install -r ../requirements.txt


        fi
    fi
    if [[ "$OSTYPE" == "linux-arm"* ]]; then
        checkraspi
        if hash apt 2>/dev/null; then
            apt install "$AWK"
            report
            echo 'Using apt...'

        fi
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
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

