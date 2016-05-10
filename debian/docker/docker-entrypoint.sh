#!/usr/bin/env bash
# **************************************************
# Additional script that run internally in the docker image.
#

APP_DIR="/app"

STEP=0
STEPS=1

((STEP++))
echo "$STEP/$STEPS. Now copying the *.deb files in  '$APP_DIR'..."
cp /*.deb $APP_DIR

#cp /*.deb /app
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered copying the  *.deb files."
    exit 1
fi