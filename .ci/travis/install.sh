#!/bin/bash

set -e
set -x

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if [[ "$(uname -s)" == 'Darwin' ]]; then
    brew update || brew update
    brew outdated pyenv || brew upgrade pyenv
    brew install pyenv-virtualenv
fi

if [[ "$(uname -s)" == 'Linux' ]]; then
    sudo apt-get update && sudo apt-get install aptitude

    if [[ $ARCH == "32" ]]; then
        sudo dpkg --add-architecture i386
        sudo aptitude update && sudo aptitude install -y wget curl llvm:i386 build-essential:i386 libc6:i386 libstdc++6:i386 libbz2-dev:i386 \
            libexpat1-dev:i386 ncurses-dev:i386 libssl-dev:i386 zlib1g-dev:i386 libreadline-dev:i386 \
            libsqlite3-dev:i386 xz-utils:i386 tk-dev:i386 libxml2-dev:i386 libxmlsec1-dev:i386
        echo "TARGET=$(dpkg-architecture -ai386 -qDEB_HOST_GNU_TYPE); CC="$(dpkg-architecture -ai386 -qDEB_HOST_GNU_TYPE)-gcc"; export CC TARGET" | tee -a ~/.bashrc
        CC="$(dpkg-architecture -ai386 -qDEB_HOST_GNU_TYPE)-gcc" dpkg-architecture -ai386 -s | tee -a ~/.bashrc
    else
        sudo aptitude update && sudo aptitude install -y git-core make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
            libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev
    fi

    dpkg-architecture -ai386 -c 'gcc -v'
    dpkg-architecture -aamd64 -c 'gcc -v'
    gcc -v

    sudo aptitude purge -y python-virtualenv

    rm -rf /opt/pyenv/plugins/pyenv-virtualenv || true
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
fi

if which pyenv > /dev/null; then
    eval "$(pyenv init -)"
fi


case "${PYVER}" in
    py33)
        pyenv install -f 3.3.6
        pyenv virtualenv 3.3.6 psutil
        ;;
esac
pyenv rehash
pyenv activate psutil
pyenv global 3.3.6

if [[ $TRAVIS_PYTHON_VERSION == '2.6' ]] || [[ $PYVER == 'py26' ]]; then
    pip install -U ipaddress unittest2 argparse mock==1.0.1
elif [[ $TRAVIS_PYTHON_VERSION == '2.7' ]] || [[ $PYVER == 'py27' ]]; then
    pip install -U ipaddress mock
fi

pip install -U tox coverage coveralls flake8 pep8 setuptools
