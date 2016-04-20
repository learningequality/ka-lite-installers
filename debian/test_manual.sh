#!/bin/bash
# Manually tests ka-lite by launching a dpkg with a frontend

set -e

test_version=1.2.3
echo "Starting tests"

test_fail()
{
    error=$1
    echo $error
    exit 1
}

purge()
{
    sudo -E apt-get purge -y ka-lite ka-lite-raspberry-pi
}


# Goto location of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

./test_build.sh $test_version "$1"

cd test

# Create a test assessment items archive
echo "$test_version" > assessmentitems.version
zip test.zip assessmentitems.version

# Run a test that uses a local archive
echo "ka-lite ka-lite/download-assessment-items-url select file:///$DIR/test/test.zip" | sudo debconf-set-selections
sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb
purge

echo "Done testing. Everything is purged, just re-run the script if you wanna try again with different settings."
