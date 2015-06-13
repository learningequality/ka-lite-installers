#!/bin/bash

set -e

# Version from commandline arg
VERSION=$1
# This is the debian way of writing version numbers...
DEBIAN_VERSION=`echo "$VERSION" | sed -e 's/\([0-9]*\.[0-9]*\)\.\([.]*\)/\1\~\2/g'`
# Where to find the source tarball
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
    if confirm "Do you want to build it now [y/N]"
    then
        cd ka-lite
        
        if [ -d ka_lite_static.egg-info ]
        then
            echo "Build ka-lite is more safe if you clean out all existing build files."
            if confirm "Do you want to clean the source directory's build stuff? [y/N]"
            then
                echo "Cleaning..."
                python setup.py clean --all
            else
                echo "Not cleaning"
            fi
        fi
        
        python setup.py sdist --static
        cd $THIS_DIR
        if [ ! -f "$SOURCE_TARBALL" ]
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
    if confirm "Yes, clean and rebuild [y/N]"
    then
        rm "$SOURCE_TARBALL"
        rm -rf "deb_dist/tmp_py2dsc/ka-lite-static-$VERSION"
        cd ka-lite
        rm -rf dist-packages
        python setup.py clean --all
        python setup.py sdist --static
    else
        echo "Continuing build process with existing setuptools sdist"
    fi
fi

cd $THIS_DIR

# Build the static package
py2dsc --extra-cfg-file=stdeb.cfg --ignore-install-requires $SOURCE_TARBALL

# Depends: ${misc:Depends}
echo "Removing stdeb's autogenerated python dependencies..."
sed -i 's/\${python:Depends}//g' "deb_dist/ka-lite-source-${DEBIAN_VERSION}/debian/control"
# sed -i 's/python\:Depends\=.*/python\:Depends\=/g' "deb_dist/ka-lite-source-$DEBIAN_VERSION/debian/ka-lite.substvars"

echo "Building final debian package for all architectures..."
cd deb_dist/ka-lite-source-$DEBIAN_VERSION
dpkg-buildpackage -rfakeroot -pgpg -k1EC66E61
cd $THIS_DIR

echo "Sources created"
echo "You should commit relevant files to the repo, because we track old releases."
echo "TODO: Figure out which files should be tracked"
echo ""
echo "A new .deb file is now available in deb_dist:"
echo ""
echo "    deb_dist/ka-lite_${DEBIAN_VERSION}-1_all.deb"
echo ""
