#!/usr/bin/env bash
# **************************************************
# Additional script that run internally in the docker image.
#
# Steps
#   1. Move the *.deb in the `temp/installers` directory

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
TEMP_DIR_NAME="ka-lite-source-0.16.6"
WORKING_DIR="/$TEMP_DIR_NAME"
DEB_INSTALLER_DIR="installers"

COLLECT_DEB_MV="mv /*.deb  $WORKING_DIR/$DEB_INSTALLER_DIR"

STEP=0
STEPS=1

echo "Now running the Additional script..."

((STEP++))
echo "$STEP/$STEPS. Now copying the *.deb files in  '$COLLECT_DEB_CMD'..."


cd "$WORKING_DIR"
if ! [ -d "$WORKING_DIR/$DEB_INSTALLER_DIR" ]; then
    echo ".. Creating temporary directory named '$WORKING_DIR/$DEB_INSTALLER_DIR'..."
    mkdir "$DEB_INSTALLER_DIR"
fi

$COLLECT_DEB_MV
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$WORKING_DIR/$DEB_INSTALLER_DIR'."
    exit 1
fi
