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

#Python has been installed as
#  /usr/local/opt/python@3.9/bin/python3
#
#Unversioned symlinks `python`, `python-config`, `pip` etc. pointing to
#`python3`, `python3-config`, `pip3` etc., respectively, have been installed into
#  /usr/local/opt/python@3.9/libexec/bin
#
#You can install Python packages with
#  /usr/local/opt/python@3.9/bin/pip3 install <package>
#They will install into the site-package directory
#  /usr/local/lib/python3.9/site-packages
#
#See: https://docs.brew.sh/Homebrew-and-Python
#
#python@3.9 is keg-only, which means it was not symlinked into /usr/local,
#because this is an alternate version of another formula.
#
#If you need to have python@3.9 first in your PATH, run:
#  echo 'export PATH="/usr/local/opt/python@3.9/bin:$PATH"' >> /Users/git/.bash_profile
#
#For compilers to find python@3.9 you may need to set:
#  export LDFLAGS="-L/usr/local/opt/python@3.9/lib"
#
#For pkg-config to find python@3.9 you may need to set:
#  export PKG_CONFIG_PATH="/usr/local/opt/python@3.9/lib/pkgconfig"

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


if ! hash docker-compose 2>/dev/null; then
    sudo apt-get install docker-compose
fi

if hash apt-get 2>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y python3
    sudo apt-get install python3-pip
    if ! hash python3 2>/dev/null; then
        sudo apt-get install -y build-essential \
            tk-dev libncurses5-dev libncursesw5-dev \
            libreadline6-dev libdb5.3-dev libgdbm-dev \
            libsqlite3-dev libssl-dev libbz2-dev \
            libexpat1-dev liblzma-dev zlib1g-dev libffi-dev
        wget https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tar.xz
        tar xf Python-3.9.0.tar.xz
        cd Python-3.9.0
        ./configure --enable-optimizations --prefix=/usr
        make
        sudo make altinstall
        cd ..
        sudo rm -r Python-3.9.0
        rm Python-3.9.0.tar.xz
        . ~/.bashrc
        sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1
        python -V
        exit
    fi
    if ! hash pip3 2>/dev/null; then
	sudo apt-get install python3-pip
    fi
exit
fi

if hash brew 2>/dev/null; then
    brew install awk
    brew install python@3.9
    [ -f "/usr/local/opt/python@3.9/bin/python3" ] && python39=/usr/local/opt/python@3.9/bin/python3
    [ -f "/opt/homebrew/opt/python@3.9/bin/python3" ] && python39=/opt/homebrew/opt/python@3.9/bin/python3
    export python39
    $python39 -m pip install --upgrade pip
    $python39 -m pip install omegaconf
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
            sudo apt install gawk
            sudo apt update
            sudo apt install software-properties-common
            report
            echo 'Using apt...'
            checkbrew
        fi
    fi
    if [[ "$OSTYPE" == "linux-musl" ]]; then
        if hash apk 2>/dev/null; then
            apk add awk
            report
            echo 'Using apk...'
            checkbrew
        fi
    fi
    if [[ "$OSTYPE" == "linux-arm"* ]]; then
        checkraspi
        if hash apt 2>/dev/null; then
            apt install awk
            report
            echo 'Using apt...'
            checkbrew
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

