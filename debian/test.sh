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


# A user account which is used for some tests and deleted after.
TEST_USER="kalite_test"

if [ "$1" = "" ]
then
    target_kalite=true
    target_rpi=true
    target_bundle=true
    target_upgrade=true
    target_bundle_manual_init=true
else
    target_kalite=false
    target_rpi=false
    target_bundle=false
    target_upgrade=false
    target_bundle_manual_init=false
    [ "$1" = "rpi" ] && target_rpi=true
    [ "$1" = "kalite" ] && target_kalite=true
    [ "$1" = "bundle" ] && target_bundle=true
    [ "$1" = "upgrade" ] && target_upgrade=true
    [ "$1" = "manual_init" ] && target_bundle_manual_init=true
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

    # Use the test user
    echo "ka-lite ka-lite/user select $TEST_USER" | sudo debconf-set-selections

    # Simple install of ka-lite with no prior debconf set...
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite_${test_version}_all.deb" "tail"
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
    # Test that the script restarts
    sudo service ka-lite restart
    # Test that status command is possible
    sudo service ka-lite status
    sudo -E apt-get purge -y ka-lite-bundle

    echo "Done with ka-lite-bundle tests"
fi


echo ""
echo "======================================="
echo " Testing ka-lite-bundle w/o update.rcd"
echo "======================================="
echo ""


if $target_bundle_manual_init
then

    # Remove all previous values from debconf
    echo "Purging any prior values in debconf"
    echo PURGE | sudo debconf-communicate ka-lite-bundle

    echo "ka-lite-bundle ka-lite/init select false" | sudo debconf-set-selections

    # Test ka-lite-bundle
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite-bundle_${test_version}_all.deb" "tail"
    kalite status
    # Test that the script restarts
    sudo service ka-lite start
    sudo service ka-lite stop
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

    sudo -E apt-get install -y -q nginx-light
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite-raspberry-pi_${test_version}_all.deb" "tail"
    kalite status
    # Test that the script restarts
    sudo service ka-lite restart

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

    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite-raspberry-pi_${test_version}_all.deb" "tail"
    test_command_with_pipe "sudo -E dpkg -i --debug=2 ka-lite-raspberry-pi_${test_version}.1_all.deb" "tail"
    sudo -E apt-get purge -y ka-lite-raspberry-pi

    sudo -E apt-get purge -y nginx-common

    echo "Done with upgrade tests"


fi

echo ""
echo "=============================="
echo " Cleaning up"
echo "=============================="
echo ""

sudo deluser --remove-home "$TEST_USER" || echo "$TEST_USER already deleted or not created"
