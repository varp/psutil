#!/bin/bash

set -e
set -x

PYVER=`python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))'`

# setup OSX
if which pyenv > /dev/null; then
    eval "$(pyenv init -)"
fi

# install psutil

# ensure that Python is used from pyenv
pyenv global 3.3.6 && pyenv rehash
pyenv activate psutil

make clean
python setup.py build
python setup.py develop
python setup.py install


## Python and env debug
echo $PWD
which python
python -c 'import sys; print(sys.executable); print(sys.version)'
update-alternatives --display python
dpkg --get-selections | grep python
id
##

# run tests (with coverage)
if [[ $PYVER == '2.7' ]] && [[ "$(uname -s)" != 'Darwin' ]]; then
    PSUTIL_TESTING=1 python -Wa -m coverage run psutil/tests/__main__.py
else
    PSUTIL_TESTING=1 python -Wa psutil/tests/__main__.py
fi

if [ "$PYVER" == "2.7" ] || [ "$PYVER" == "3.6" ]; then
    # run mem leaks test
    PSUTIL_TESTING=1 python -Wa psutil/tests/test_memory_leaks.py
    # run linter (on Linux only)
    if [[ "$(uname -s)" != 'Darwin' ]]; then
        python -m flake8
    fi
fi
