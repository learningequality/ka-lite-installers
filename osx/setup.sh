#!/bin/bash
#
# Package script for KA-Lite on PyRun
#
# Requirements
# . git
#
# Steps
# . Execute the PyRun installer from https://downloads.egenix.com/python/install-pyrun into a tmp directory.
# . Clone KA-Lite into a directory
# . Modify `<ka-lite-folder>/python.sh` so it uses PyRun`s Python.
#
# TODO:
# * use `tempfile.py` instead of mktemp which is "subject to race conditions"

# TODO(cpauya): get the temp dir of the platform
# TODO(cpauya): use `mktemp`

# REF: http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
if [ -z ${TMPDIR+0} ]; then
    echo "$TMPDIR is not set..."
    exit 1
fi

#BASE_DIR=`basename $0`
#WORKING_DIR=`mktemp -d -t ${BASE_DIR}.XXX` || exit 1
#if [ $? -ne 0 ]; then
#   echo "$0: Can't create temp directory, exiting..."
#   exit 1
#fi

WORKING_DIR="."
echo "Using temporary directory $WORKING_DIR..."
INSTALL_PYRUN="$WORKING_DIR/install-pyrun.sh"
PYRUN_DIR="$WORKING_DIR/pyrun-2.7"
PYRUN="$PYRUN_DIR/bin/pyrun"
KA_LITE_ZIP="$WORKING_DIR/ka-lite.zip"
KA_LITE_DIR="$WORKING_DIR/ka-lite"

# Install PyRun
if [ -e "$INSTALL_PYRUN" ]; then
    echo "Found '$INSTALL_PYRUN' so will not re-download.  Delete this file to re-download."
else
    echo "Downloading 'install-pyrun' script..."
    curl https://downloads.egenix.com/python/install-pyrun > $INSTALL_PYRUN
    chmod +x $INSTALL_PYRUN
fi

if [ -d "$PYRUN_DIR" ]; then
    echo "Found PyRun directory at '$PYRUN_DIR' so will not re-download.  Delete this directory to re-download."
else
    echo "Installing minimal PyRun with Python 2.7..."
    $INSTALL_PYRUN -m --python=2.7 $PYRUN_DIR
fi

# Get KA-Lite
if [ -e "$KA_LITE_ZIP" ]; then
	echo "Found '$KA_LITE_ZIP' file so will not re-download.  Delete this file to re-download."
else
    echo "Downloading 'kalite' zip..."
    # REF: http://stackoverflow.com/a/18222354/845481
    # How to download source in .zip format from GitHub?
    # TODO(cpauya): Point to the `learningequality` account when merged.
    curl -L -o $KA_LITE_ZIP https://github.com/benjaoming/ka-lite/zipball/kalite-command/
fi

if [ -d "$KA_LITE_DIR" ]; then
	echo "Found ka-lite directory '$KA_LITE_DIR' so will not re-download.  Delete this folder to re-download."
else
    echo "Extracting 'ka-lite.zip'..."
    unzip $KA_LITE_ZIP -d $KA_LITE_DIR
fi

