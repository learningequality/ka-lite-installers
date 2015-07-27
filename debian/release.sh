#!/bin/bash

if [ ! -d build ]
then
	echo "No build/ dir found"
	exit 1
fi

cd build

if [ ! "$1" ]
then
	echo "You need to specify a version"
	exit 1
fi

# Version from commandline arg
VERSION=$1

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

if echo $VERSION | egrep '(a|b|c|dev|post)'
then
	echo "The upstream version syntax does not appear compatible with Debian."
	echo "Examples of debian compatible versions:"
	echo "   0.14~0dev123"
	echo "   0.14~a1"
	echo "   0.14~b1"
	echo "   0.14~post123"
	read -r -p "Please input a debian compatible version: " DEBIAN_VERSION
	echo "Using $DEBIAN_VERSION"
fi

echo ""

echo "Now fetching ka-lite-static==$VERSION with pip"

pip install --download=. --no-deps ka-lite-static==$VERSION

old_version="`apt-cache show ka-lite | grep Version | sed 's/Version: //'`"

echo "Basing this on $old_version"

version_clean_from_package_revisions="`echo $old_version | sed 's/-.*//'`"

debian_source_dir="ka-lite-source-$version_clean_from_package_revisions"

echo "Assuming sources in $debian_source_dir"

apt-get source ka-lite

cd $debian_source_dir

uupdate -v $DEBIAN_VERSION ../ka-lite-static-$VERSION.tar.gz

cd ../ka-lite-source-$DEBIAN_VERSION

echo "New source prepared! Please run 'dch' to write a changelog and run 'dpkg-buildpackage -S', followed by 'dput ppa://learningequality/ka-lite'"
