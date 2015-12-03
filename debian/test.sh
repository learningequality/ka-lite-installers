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
    target_upgrade=true
else
    target_kalite=false
    target_rpi=false
    target_bundle=false
    target_upgrade=false
    [ "$1" = "rpi" ] && target_rpi=true
    [ "$1" = "kalite" ] && target_kalite=true
    [ "$1" = "bundle" ] && target_bundle=true
    [ "$1" = "upgrade" ] && target_upgrade=true
fi


test_fail()
{
    error=$1
    echo $error
    exit 1
}

get_conf_value()
{
  pkg=$1
  conf=$2
  echo `debconf-show $pkg | grep $2 | sed 's/.*:\s//'`
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


if $target_kalite
then
    # Run a test that uses a local archive
    echo "ka-lite ka-lite/download-assessment-items-url select file://$DIR/test/test.zip" | sudo debconf-set-selections
    sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb | tail
    [ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
    tmp_location=`get_conf_value ka-lite ka-lite/download-assessment-items-tmp`
    [ -f "$tmp_location/assessment_items.zip" ] && test_fail "Temporary zip not cleaned up"
    sudo -E apt-get purge -y ka-lite

    # Run a test that uses a local archive
    echo "ka-lite ka-lite/download-assessment-items-url select file://$DIR/test/test.zip" | sudo debconf-set-selections
    sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb | tail
    [ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
    # Should not delete archive in this case
    [ -f "$DIR/test/test.zip" ] || test_fail "local zip archive deleted after usage"
    kalite status
    sudo -E apt-get purge -y ka-lite

    # Run a test that downloads assessment items
    echo "ka-lite ka-lite/download-assessment-items-url select http://overtag.dk/upload/assessment_test.zip" | sudo debconf-set-selections
    sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb | tail
    [ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
    kalite status
    sudo -E apt-get purge -y ka-lite

    # Run a test that uses a specific /tmp location
    echo "ka-lite ka-lite/download-assessment-items-url select file://$DIR/test/test.zip" | sudo debconf-set-selections
    mkdir -p /tmp/test
    echo "ka-lite ka-lite/download-assessment-items-tmp select /tmp/test" | sudo debconf-set-selections
    sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb | tail
    [ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
    kalite status
    sudo -E apt-get purge -y ka-lite

    echo "Done with normal ka-lite tests"

fi


if $target_bundle
then

    # Test ka-lite-bundle
    sudo -E dpkg -i --debug=2 ka-lite-bundle_${test_version}_all.deb | tail
    kalite status
    sudo -E apt-get purge -y ka-lite-bundle

    echo "Done with ka-lite-bundle tests"
fi

if $target_rpi
then

    # Test ka-lite-raspberry-pi
    echo "ka-lite-raspberry-pi ka-lite/download-assessment-items-url select file://$DIR/test/test.zip" | sudo debconf-set-selections
    sudo -E apt-get install -y -q nginx-light
    sudo -E dpkg -i --debug=2 ka-lite-raspberry-pi_${test_version}_all.deb | tail
    # gdebi is not allowed
    # sudo -E gdebi --n ka-lite-raspberry-pi_${test_version}_all.deb
    kalite status
    sudo -E apt-get purge -y ka-lite-raspberry-pi
    # Ensure that there is nothing left after purging, otherwise divertion process failed
    [ -f /etc/nginx/nginx.conf ] || test_fail "/etc/nginx/nginx.conf was not restored"
    sudo -E apt-get purge -y nginx-common
    # Ensure that there is nothing left after purging, otherwise divertion process failed
    ! [ -d /etc/nginx ] || test_fail "/etc/nginx not empty after purging nginx"
    echo "Done with RPi tests"
fi


# Test upgrades
if $target_upgrade
then
    # Install previous test
    echo "ka-lite ka-lite/download-assessment-items-url select file://$DIR/test/test.zip" | sudo debconf-set-selections
    sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb | tail

    # Then install a version with .1 appended
    cd $DIR
    ./test_build.sh ${test_version}.1 1
    cd test
    sudo -E dpkg -i --debug=2 ka-lite_${test_version}.1_all.deb | tail
    sudo -E apt-get purge -y ka-lite
    echo "Done with upgrade tests"
fi
