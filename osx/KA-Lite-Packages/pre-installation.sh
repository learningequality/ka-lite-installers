#!/bin/bash

WORKING_DIR="/Applications/KA-Lite-Monitor.app/Contents/Resources"
PYRUN_NAME="pyrun-2.7"
PYRUN_DIR="$WORKING_DIR/$PYRUN_NAME"

KA_LITE="ka-lite"
KA_LITE_ZIP="$WORKING_DIR/$KA_LITE.zip"
KA_LITE_DIR="$WORKING_DIR/$KA_LITE"

KA_LITE_REPO_ZIP="https://github.com/learningequality/ka-lite/archive/develop.zip"

if [ -d $PYRUN_DIR ]; then
    echo "Pyrun already Installed"
else
    echo "Installing Pyrun"
    curl https://downloads.egenix.com/python/install-pyrun > "$WORKING_DIR/install-pyrun.sh"
fi

