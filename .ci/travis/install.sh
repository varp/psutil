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
    sudo apt-get install -y git-core build-essential pbuilder autoconf
#    sudo apt-get install -y build-essential:i386

    rm -rf /opt/pyenv/plugins/pyenv-virtualenv || true
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
fi


if which pyenv > /dev/null; then
    eval "$(pyenv init -)"
fi

case "${PYVER}" in
    py33)
        pyenv install 3.3.6
        pyenv virtualenv 3.3.6 psutil
        ;;
esac
pyenv rehash
pyenv activate psutil


if [[ $TRAVIS_PYTHON_VERSION == '2.6' ]] || [[ $PYVER == 'py26' ]]; then
    pip install -U ipaddress unittest2 argparse mock==1.0.1
elif [[ $TRAVIS_PYTHON_VERSION == '2.7' ]] || [[ $PYVER == 'py27' ]]; then
    pip install -U ipaddress mock
fi

pip install -U coverage coveralls flake8 pep8 setuptools
