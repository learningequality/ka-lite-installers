#!/bin/bash

# KA Lite sources are really big, this script takes an original KA Lite
# debian source and creates one without all the fuzz.

set -e

if
	[ "$1" == "-h" ] ||
	[ "$1" == "--help" ]
then
	echo "Copies the debian/ contents of a package to this folder "
	echo "where we maintain the debian/ source in Git."
	echo "usage: ./copy_from_pkg [path-of-pkg]"
	exit
fi

# Goto location of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

if [ "$1" == "" ]
then
	test_dir=test/ka-lite-test
else
	test_dir=$1
fi

dest_dir=`realpath .`

if ! [ -d $test_dir/debian ]
then
	echo "No debian/ found in $test_dir"
	exit 1
fi

test_dir=`realpath $test_dir`

echo "This will overwrite the contents of"
echo "$dest_dir"
echo "with the contents of"
echo "$test_dir"
echo ""

read -p "Are you sure? [y/N] " choice

case "$choice" in
	y|Y )
		git rm -rf --ignore-unmatch --cached $dest_dir/debian/*
		git add $dest_dir/debian
		# Copy everything except the assessment zip from the test pkg dir to this dir
		cd $test_dir
		debclean
		cd -
		# The below has to run with respect to relative paths, hence the cd and the cp --parents
		cd $test_dir
		find debian -mindepth 1 -not -name '*.zip' -exec cp -rp \{\} --parents $dest_dir \;
		rm $dest_dir/debian/changelog
		git reset -- $dest_dir/debian/changelog
		git checkout $dest_dir/debian/changelog
;;
	n|N ) echo "no" ;;
	* ) echo "Okay leaving then..." ;;
esac
