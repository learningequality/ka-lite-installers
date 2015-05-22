#!/bin/bash

VERSION=$1
SOURCE_TARBALL="ka-lite/dist/ka-lite-static-$VERSION.tar.gz"
THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if ! which py2dsc
then
    echo "You need to install stdeb -- sudo pip install stdeb or apt-get install python-stdeb"
fi

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

if [ ! "$VERSION" ]
then
    echo "No version supplied, please run with version arg, e.g. ./build 1.2.3"
fi

if [ ! -f "$SOURCE_TARBALL" ]
then
    echo "Version $VERSION does not seem to exist, do you want to build the latest source?"
    if confirm "Do you want to build it now [Y/n]"
    then
        cd ka-lite
        python setup.py sdist --static
        if [ ! -f "$SOURCE_TARBALL" ]
        then
            echo "Built the wrong version, no file $SOURCE_TARBALL"
            exit 1
        fi
    else
        echo "Doing nothing"
        exit 1
    fi
fi

if [ ! -h "ka-lite" ]
then
    echo "No source package linked in. Please symlink the ka-lite source tree to 'ka-lite'"
    exit 1
fi

if `which deactivate`
then
    deactivate
fi

cd ka-lite

# Build the static package
python setup.py  --command-packages=stdeb.command sdist_dsc --static --dist-dir $THIS_DIR

echo "Sources created"
echo "You should commit relevant files to the repo, because we do track old releases. But this does not include the source code."
echo ""
echo "To compile debian package, run:"
echo ""
echo "    cd "
echo "    dpkg-buildpackage -rfakeroot -uc -us"