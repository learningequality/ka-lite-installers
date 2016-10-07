#!/bin/bash

# KA Lite sources are really big, this script takes an original KA Lite
# debian source and creates one without all the fuzz.

set -e

if [ "$1" = "" ]
then
	echo "Creates a skeleton bogus ka lite debian source from the debian/ directory in the source"
	echo "usage: ./make_test_pkg.sh VERSION"
	echo "example: ./make_test_pkg.sh 0.15.0"
	exit 1
fi

version=$1

# Goto location of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

orig_dir=`realpath .`

if [ "$2" == "" ]
then
	dest_dir=test/ka-lite-test
else
	dest_dir=$2
fi

if ! [ -d $orig_dir/debian/ ]
then
	echo "no debian/ directory"
	exit 1
fi

if ! [ -d $dest_dir ]
then
	mkdir -p $dest_dir
fi

dest_dir=`realpath "$dest_dir"`

echo "Copying from $orig_dir to $dest_dir"

cd $dest_dir
root=`pwd`/..

if ! [ -d debian ]
then
	mkdir debian
fi

# Create bogus source from a github project that maintains an empty
# skeleton of KA Lite for fake distribution
cd $root
if ! [ -d sampleproject ]
then
	echo "Cloning sampleproject"
	git clone https://github.com/benjaoming/sampleproject.git
fi

cd sampleproject
git checkout ka-lite

cd ..

bogus_sourceball=ka-lite-source_$version.orig.tar.gz

# Compress contents of sampleproject
tar cfz $bogus_sourceball -C sampleproject .

cd $dest_dir

# Uncompress into the dest
tar xfz ../$bogus_sourceball

# Has to be run at a relative path
rm -rf "$dest_dir/debian"
cd $orig_dir
find ./debian -mindepth 1 -not -name '*.zip' -exec cp -rp --parents \{\} $dest_dir \;

# Create more bogus stuff?
cd $dest_dir
touch lala
zip en.zip lala
mv en.zip debian/
rm lala

# In case this exists, it's an artifact
rm -rf *.egg-info
rm -rf .git

# Now add the version test...
dch --newversion $version -b test

#sed -i 's/ka-lite-source/ka-lite-test/' debian/control
