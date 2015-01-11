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
# . Create a kalite binary in `/usr/local/bin/` to use PyRun's Python instead of the system Python.
# . Modify `<ka-lite-folder>/python.sh` so it uses PyRun`s Python.
#
# TODO:
# * use `tempfile.py` instead of mktemp which is "subject to race conditions"

# TODO(cpauya): get the temp dir of the platform
# TODO(cpauya): use `mktemp`
# INSTALL_PYRUN="install-pyrun.sh"
# PYRUN_DIR="/tmp/ka-lite-on-pyrun"
# PYRUN="$PYRUN_DIR/bin/pyrun"

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

# TODO(cpauya): Since we are building a package for ka-lite on pyrun, shouldn't we put
# this on a more accessible location, like a folder inside the script?
WORKING_DIR="./"
echo "Using temporary directory $WORKING_DIR..."
PYRUN_DIR="$WORKING_DIR/ka-lite-on-pyrun"
INSTALL_PYRUN="$WORKING_DIR/install-pyrun.sh"
PYRUN="$PYRUN_DIR/bin/pyrun"
KA_LITE_DIR="$PYRUN_DIR/ka-lite"

# Install PyRun
echo "Downloading PyRun..."
curl https://downloads.egenix.com/python/install-pyrun > $INSTALL_PYRUN
chmod +x $INSTALL_PYRUN
echo "Installing minimal PyRun..."
$INSTALL_PYRUN -m --python=2.7 $PYRUN_DIR

# Checkout KA-Lite
# TODO(cpauya): git clone https://github.com/learningequality/ka-lite.git $KA_LITE_DIR
git clone https://github.com/learningequality/ka-lite.git $KA_LITE_DIR