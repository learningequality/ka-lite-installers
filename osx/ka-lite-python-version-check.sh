#!/usr/bin/env bash

# Print message in terminal and log for the Console application.
function msg() {
    echo "$1"
    syslog -s -l alert "KA-Lite: $1"
}

PYTHON_PATH="/usr/local/bin/python2"
KALITE_REQ_PYTHON='2.7.11'

if ! $PYTHON_PATH --version >/dev/null 2>&1; then
    PYTHON_PATH="$(which python2)"
fi

if ! $PYTHON_PATH --version >/dev/null 2>&1; then
    PYTHON_PATH="$(which python)"
fi

msg "Checking Python path at $PYTHON_PATH"
PYTHON_VERSION="$($PYTHON_PATH -c 'import platform; print(platform.python_version())')"
# REF: http://stackoverflow.com/questions/6141581/detect-python-version-in-shell-script
# REF: http://www.tldp.org/LDP/abs/html/comparison-ops.html

if [ "${PYTHON_VERSION//.}" -lt "${KALITE_REQ_PYTHON//.}" ] || [ "${PYTHON_VERSION//.}" -ge "3000" ]; then
    msg "Installed Python version $PYTHON_VERSION"
    msg "You need to upgrade Python version from $PYTHON_VERSION to $KALITE_REQ_PYTHON+"
    exit 1
fi

msg "installed Python version $PYTHON_VERSION."
exit 0
