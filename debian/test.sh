#!/bin/bash
#
# This is a special test script that will actually install KA Lite
# on the host system and test that stuff works!
# This script is intended for Travis CI mainly.

set -e

test_version=1.2.3
echo "Starting tests"

if [ "$1" = "" ]
then
    target_kalite=true
    target_rpi=true
    target_bundle=true
else
    [ "$1" = "rpi" ] && target_rpi=true || target_rpi=false
    [ "$1" = "kalite" ] && target_kalite=true || target_kalite=false
    [ "$1" = "bundle" ] && target_bundle=true || target_bundle=false
fi

test_fail()
{
    error=$1
    echo $error
    exit 1
}


# Goto location of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

./test_build.sh $test_version 1

cd test

# Create a test assessment items archive
echo "$test_version" > assessmentitems.version
zip test.zip assessmentitems.version

# Disable asking questions
export DEBIAN_FRONTEND=noninteractive


if [ $target_kalite ]
then
    # Run a test that uses a local archive
    echo "ka-lite ka-lite/download-assessment-items-url select file://$DIR/test/test.zip" | sudo debconf-set-selections
    sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb | tail
    [ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
    sudo -E apt-get purge -y ka-lite

    # Run a test that uses a local archive
    echo "ka-lite ka-lite/download-assessment-items-url select file://$DIR/test/test.zip" | sudo debconf-set-selections
    sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb | tail
    [ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
    kalite status
    sudo -E apt-get purge -y ka-lite

    # Run a test that downloads assessment items
    echo "ka-lite ka-lite/download-assessment-items-url select http://overtag.dk/upload/assessment_test.zip" | sudo debconf-set-selections
    sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb | tail
    [ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
    kalite status
    sudo -E apt-get purge -y ka-lite

fi


if [ $target_bundle ]
then

    # Test ka-lite-bundle
    sudo -E dpkg -i --debug=2 ka-lite-bundle_${test_version}_all.deb | tail
    kalite status
    sudo -E apt-get purge -y ka-lite-bundle

fi

if [ $target_rpi ]
then

    # Test ka-lite-raspberry-pi
    echo "ka-lite-raspberry-pi ka-lite/download-assessment-items-url select file://$DIR/test/test.zip" | sudo debconf-set-selections
    sudo -E apt-get install -y -q nginx-light
    sudo -E dpkg -i --debug=2 ka-lite-raspberry-pi_${test_version}_all.deb | tail
    # gdebi is not allowed
    # sudo -E gdebi --n ka-lite-raspberry-pi_${test_version}_all.deb
    kalite status
    sudo -E apt-get purge -y ka-lite-raspberry-pi
    sudo -E apt-get purge -y nginx-common

fi
