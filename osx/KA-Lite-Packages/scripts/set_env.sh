#!/usr/bin/env bash


KALITE_SHARED="/Users/Shared/kalite"
KALITE_DIR="~/.kalite"

PYRUN_NAME="pyrun-2.7"
PYRUN_DIR="$KALITE_SHARED/$PYRUN_NAME"
PYRUN="$PYRUN_DIR/bin/pyrun"
PYRUN_PIP="$PYRUN_DIR/bin/pip"
BIN_PATH="$PYRUN_DIR/bin"

#----------------------------------------------------------------------
# Functions
#----------------------------------------------------------------------
function update_env {
    # MUST: Make sure we have a KALITE_PYTHON env var that points to Pyrun
    echo "Updating KALITE_PYTHON environment variable..."
    # export KALITE_PYTHON="$PYRUN"
    launchctl setenv KALITE_PYTHON "$PYRUN"
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Error/s encountered exporting KALITE_PYTHON '$PYRUN'."
        exit 1
    fi
}

#----------------------------------------------------------------------
# Script
#----------------------------------------------------------------------
update_env