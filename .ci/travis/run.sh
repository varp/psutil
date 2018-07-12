#!/bin/bash

set -e
set -x

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"


PYVER=`python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))'`

# setup OSX
if which pyenv > /dev/null; then
    eval "$(pyenv init -)"
fi

# ensure that Python is used from pyenv
pyenv rehash
pyenv global 3.3.6
pyenv activate psutil

make clean

if [[ $ARCH == "32" ]]; then
#    eval "TARGET=$(dpkg-architecture -ai386 -qDEB_HOST_GNU_TYPE); export TARGET"

     BASECFLAGS="-m32 -march=i686" LDFLAGS="-m32 -march=i686" CFLAGS="-m32 -march=i686" python setup.py build
else
    python setup.py build
fi

python setup.py develop
python setup.py sdist bdist_wheel
python setup.py install


## Python and env debug
#if [[ "$(uname -s)" == "Linux" ]]; then
#    echo $PWD
#    which python
#    python -c 'import sys; print(sys.executable); print(sys.version)'
#    update-alternatives --display python || true
#    dpkg --get-selections | grep python
#    id
#fi
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
