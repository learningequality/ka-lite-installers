#!/bin/bash
#
# This is a special test script that will actually install KA Lite
# on the host system and test that stuff works!
# This script is intended for Travis CI mainly.

set -e

# Goto location of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

# Traceback utility for Bash
. "$DIR/traceback.sh"

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
    echo ""
    echo "!!! exiting due to test failure"
    echo "!!! $error"
    exit 1
}

# When piping, you loose the status code and non-0 exit commands are lost
# so we need this...
test_command_with_pipe()
{
    cmd=$1
    pipe=$2
    $1 | $2
    if [ ! ${PIPESTATUS[0]} -eq 0 ]
    then
        exit 123
    fi
}

get_conf_value()
{
  pkg=$1
  conf=$2
  echo `debconf-show $pkg | grep $2 | sed 's/.*:\s//'`
}

./test_build.sh $test_version 1

cd test

# Create a test assessment items archive
echo "$test_version" > assessmentitems.version
zip test.zip assessmentitems.version

# Disable asking questions
export DEBIAN_FRONTEND=noninteractive


echo ""
echo "=============================="
echo " Testing ka-lite"
echo "=============================="
echo ""


if $target_kalite
then

    # Remove all previous values from debconf
    echo "Purging any prior values in debconf"
    echo PURGE | sudo debconf-communicate ka-lite

    # Run a test that uses a local archive
    echo "ka-lite ka-lite/download-assessment-items-url select file:///$DIR/test/test.zip" | sudo debconf-set-selections
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb" "tail"
    [ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
    tmp_location=`get_conf_value ka-lite ka-lite/download-assessment-items-tmp`
    [ -f "$tmp_location/assessment_items.zip" ] && test_fail "Temporary zip not cleaned up"
    sudo -E apt-get purge -y ka-lite

    # Run a test that uses a local archive
    echo "ka-lite ka-lite/download-assessment-items-url select file:///$DIR/test/test.zip" | sudo debconf-set-selections
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb" "tail"
    [ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
    # Should not delete archive in this case
    [ -f "$DIR/test/test.zip" ] || test_fail "local zip archive deleted after usage"
    kalite status
    sudo -E apt-get purge -y ka-lite

    # Run a test that downloads assessment items
    echo "ka-lite ka-lite/download-assessment-items-url select http://overtag.dk/upload/assessment_test.zip" | sudo debconf-set-selections
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb" "tail"
    [ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
    kalite status
    sudo -E apt-get purge -y ka-lite

    # Run a test that uses a specific /tmp location
    echo "ka-lite ka-lite/download-assessment-items-url select file:///$DIR/test/test.zip" | sudo debconf-set-selections
    mkdir -p /tmp/test
    echo "ka-lite ka-lite/download-assessment-items-tmp select /tmp/test" | sudo debconf-set-selections
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb" "tail"
    [ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
    kalite status
    sudo -E apt-get purge -y ka-lite

    echo "Done with normal ka-lite tests"

fi

echo ""
echo "=============================="
echo " Testing ka-lite-bundle"
echo "=============================="
echo ""


if $target_bundle
then

    # Remove all previous values from debconf
    echo "Purging any prior values in debconf"
    echo PURGE | sudo debconf-communicate ka-lite-bundle

    # Test ka-lite-bundle
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite-bundle_${test_version}_all.deb" "tail"
    kalite status
    sudo -E apt-get purge -y ka-lite-bundle

    echo "Done with ka-lite-bundle tests"
fi

echo ""
echo "=============================="
echo " Testing ka-lite-raspberry-pi"
echo "=============================="
echo ""

if $target_rpi
then

    # Remove all previous values from debconf
    echo "Purging any prior values in debconf"
    echo PURGE | sudo debconf-communicate ka-lite-raspberry-pi

    # Test ka-lite-raspberry-pi
    echo "ka-lite-raspberry-pi ka-lite/download-assessment-items-url select file:///$DIR/test/test.zip" | sudo debconf-set-selections
    sudo -E apt-get install -y -q nginx-light
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite-raspberry-pi_${test_version}_all.deb" "tail"
    kalite status
    # Ensure there's a file created with the .kalite dir
    [ -f /etc/ka-lite/nginx.d/username.conf ] || test_fail "/etc/ka-lite/nginx.d/username.conf was not created"
    sudo -E apt-get purge -y ka-lite-raspberry-pi
    [ -f /etc/nginx/nginx.conf ] || test_fail "/etc/nginx/nginx.conf was not restored"
    sudo -E apt-get purge -y nginx-common
    # Ensure that there is nothing left after purging, otherwise divertion process failed
    ! [ -d /etc/nginx ] || test_fail "/etc/nginx not empty after purging nginx"
    echo "Done with RPi tests"
fi


echo ""
echo "=============================="
echo " Testing upgrades"
echo "=============================="
echo ""


# Test upgrades
if $target_upgrade
then
    # Install previous test
    echo "ka-lite ka-lite/download-assessment-items-url select file:///$DIR/test/test.zip" | sudo debconf-set-selections
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb" "tail"

    # Then install a version with .1 appended
    cd $DIR
    ./test_build.sh ${test_version}.1 1
    cd test

    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite_${test_version}.1_all.deb" "tail"
    sudo -E apt-get purge -y ka-lite

    
    # ka-lite-raspberry-pi
    # ...the one with diversions!
    # Install previous test

    sudo -E apt-get install -y -q nginx-light

    echo "ka-lite ka-lite/download-assessment-items-url select file:///$DIR/test/test.zip" | sudo debconf-set-selections
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite-raspberry-pi_${test_version}_all.deb" "tail"
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite-raspberry-pi_${test_version}.1_all.deb" "tail"
    sudo -E apt-get purge -y ka-lite-raspberry-pi
  
    sudo -E apt-get purge -y nginx-common

    echo "Done with upgrade tests"


fi
