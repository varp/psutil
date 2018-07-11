#!/bin/bash

set -e
set -x

echo "+ CURRENT BUILD PATH == $(pwd)"
uname -a
python -c "import sys; print(sys.version)"

if [[ "$(uname -s)" == 'Darwin' ]]; then
    brew update || brew update
    brew outdated pyenv || brew upgrade pyenv
    brew install pyenv-virtualenv
fi

if [[ "$(uname -s)" == 'Linux' ]]; then
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install -y git-core gcc-multilib make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
        libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev
    sudo apt-get purge -y python-virtualenv

    rm -rf /opt/pyenv/plugins/pyenv-virtualenv || true
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
fi


if which pyenv > /dev/null; then
    eval "$(pyenv init -)"
fi

case "${PYVER}" in
    py33)
        sudo pyenv install -f 3.3.6
        sudo pyenv virtualenv 3.3.6 psutil
        ;;
esac
sudo pyenv rehash
sudo pyenv activate psutil
sudo pyenv global 3.3.6

if [[ $TRAVIS_PYTHON_VERSION == '2.6' ]] || [[ $PYVER == 'py26' ]]; then
    sudo pip install -U ipaddress unittest2 argparse mock==1.0.1
elif [[ $TRAVIS_PYTHON_VERSION == '2.7' ]] || [[ $PYVER == 'py27' ]]; then
    sudo pip install -U ipaddress mock
fi

sudo pip install -U tox coverage coveralls flake8 pep8 setuptools
