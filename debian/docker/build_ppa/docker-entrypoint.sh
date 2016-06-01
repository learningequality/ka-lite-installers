#!/usr/bin/env bash
# **************************************************
# Additional script that run internally in the docker image.
#

APP_DIR="/installers"

STEP=0
STEPS=1

echo "Now running the Additional script..."

((STEP++))
echo "$STEP/$STEPS. Now copying the *.deb files in  '$APP_DIR'..."
cp /*.deb $APP_DIR
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered copying the  *.deb files."
    exit 1
fi