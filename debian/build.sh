#!/bin/bash

VERSION=$1
SOURCE_TARBALL="ka-lite/dist/ka-lite-static-$VERSION.tar.gz"
THIS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ ! "$VERSION" ]
then
    echo "No version supplied, please run with version arg, e.g. ./build 1.2.3"
    exit 1
fi

pydsc2_installed=`which py2dsc`
if [ ! "$pydsc2_installed" ]
then
    echo "You need to install stdeb -- sudo pip install stdeb or apt-get install python-stdeb"
    exit 1
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

if [ ! -f $SOURCE_TARBALL ]
then
    echo "Version $VERSION does not seem to exist, do you want to build the latest source?"
    if confirm "Do you want to build it now [Y/n]"
    then
        cd ka-lite
        
        if [ -d ka_lite_static.egg-info ]
        then
            echo "Build ka-lite is more safe if you clean out all existing build files."
            if confirm "Do you want to clean the source directory's build stuff? [Y/n]"
            then
                echo "Cleaning..."
                python setup.py clean --all
            else
                echo "Not cleaning"
            fi
        fi
        
        python setup.py sdist --static
        if [ ! -f $SOURCE_TARBALL ]
        then
            echo "Built the wrong version, no file $SOURCE_TARBALL"
            exit 1
        fi
    else
        echo "Doing nothing"
        exit 1
    fi
else
    echo "It's already built but do you need to clean everything and rebuild?"
    if confirm "Yes, clean and rebuild [Y/n]"
    then
        cd ka-lite
        python setup.py clean --all
        python setup.py sdist --static
    else
        echo "Continuing build process with existing setuptools sdist"
    fi
fi

cd $THIS_DIR

# Build the static package
py2dsc $SOURCE_TARBALL

DEBIAN_VERSION=echo "$VERSION" | sed -e 's/\([0-9]*\.[0-9]*\)\.\([.]*\)/\1\~\2/g'

echo "Sources created"
echo "You should commit relevant files to the repo, because we do track old releases. But this does not include the source code."
echo ""
echo "To compile debian package, run:"
echo ""
echo "    cd deb_dist/ka-lite-static-$DEBIAN_VERSION"
echo "    dpkg-buildpackage -rfakeroot -uc -us"