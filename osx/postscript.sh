#!/usr/bin/env bash

echo "Now preparing KA-Lite dependencies.."

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

PYRUN_NAME="pyrun-2.7"
PYRUN_DIR="/Users/Shared/$PYRUN_NAME"
PYRUN="$PYRUN_DIR/bin/pyrun"
PYRUN_PIP="$PYRUN_DIR/bin/pip"
BIN_PATH="$PYRUN_DIR/bin"
ASSESSMENT_SRC="/Users/Shared/assessment/assessment.zip"

function update_env {
    echo "Updating KALITE_PYTHON environment variable"
    launchctl setenv  KALITE_PYTHON "$PYRUN"
    if [ $? -ne 0 ]; then
        echo "  $0: Error/s encountered  exporting KALITE_PYTHON '$KA_LITE_APP_PATH', exiting..."
        exit 1
    fi
}

if [ -z ${KALITE_PYTHON+0} ]; then
    update_env
else
    if [ "KALITE_PYTHON" != $PYRUN ]; then
        update_env
    fi
fi

python $BIN_PATH/shebangcheck.py

echo "Running  manage setup.."
kalite manage setup --noinput
if [ $? -ne 0 ]; then
    echo "  $0: Error/s encountered running 'bin/kalite manage setup', exiting..."
    exit 1
fi

echo "Unpacking assessment.zip"
kalite manage unpack_assessment_zip $ASSESSMENT_SRC
if [ $? -ne 0 ]; then
    echo "  $0: Error/s encountered running 'bin/kalite manage unpack_assessment_zip', exiting..."
    exit 1
fi
