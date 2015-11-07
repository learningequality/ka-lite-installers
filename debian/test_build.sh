#!/bin/bash

set -e

# Builds the test package

test_version="$1"
build_dir="test/ka-lite-ci-test"

if [ "$1" = "" ]
then
	echo "usage: ./script VERSION"
	exit 1
fi

keep_old_build=`echo "$2" | xargs`

# Goto location of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

if [ -d "$build_dir" ] && [ "$keep_old_build" = "" ]
then
     echo "Already built, skipping"
     exit 0
fi

# Remove old test if exists
rm -rf "$build_dir"

# Create a new test package
./make_test_pkg.sh $test_version "$build_dir"
cd "$build_dir"

# Build the test package
debuild --no-lintian -us -uc | tail

# Go to the build dir
cd $DIR

