#!/bin/bash
#
# This is a special test script that will actually install KA Lite
# on the host system and test that stuff works!
#

set -e

test_version=1.2.3
echo "Starting tests"

test_fail()
{
    error=$1
    echo $error
    exit 1
}


# Goto location of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

# Create a new test package
./make_test_pkg.sh $test_version test/ka-lite-ci-test
cd test/ka-lite-ci-test

# Build the test package
debuild --no-lintian -us -uc

# Go to the build dir
cd ..

# Create a test assessment items archive
echo "$test_version" > assessmentitems.version
zip test.zip assessmentitems.version

# Disable asking questions
export DEBIAN_FRONTEND=noninteractive


# Run a test that uses a local archive
echo "ka-lite ka-lite/download-assessment-items-url select file://$DIR/test/test.zip" | sudo debconf-set-selections
sudo -E dpkg -i --debug=3773 ka-lite_${test_version}_all.deb

[ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"

# Run a test that uses a local archive
echo "ka-lite ka-lite/download-assessment-items-url select file://$DIR/test/test.zip" | sudo debconf-set-selections
sudo -E dpkg -i --debug=3773 ka-lite_${test_version}_all.deb
[ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
kalite status
sudo apt-get purge -y ka-lite

# Run a test that downloads assessment items
echo "ka-lite ka-lite/download-assessment-items-url select http://overtag.dk/upload/assessment_test.zip" | sudo debconf-set-selections
sudo -E dpkg -i ka-lite_${test_version}_all.deb
[ -f /usr/share/kalite/assessment/khan/assessmentitems.version ] || test_fail "Did not find assessment items"
kalite status
sudo apt-get purge -y ka-lite


# Test ka-lite-bundle
sudo -E dpkg -i --debug=3773 ka-lite-bundle_${test_version}_all.deb
kalite status
sudo apt-get purge -y ka-lite-bundle


# Test ka-lite-raspberry-pi
sudo -E dpkg -i --debug=3773 ka-lite-raspberry-pi_${test_version}_all.deb
kalite status
sudo apt-get purge -y ka-lite-raspberry-pi

