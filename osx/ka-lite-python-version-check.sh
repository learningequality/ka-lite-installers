#!/usr/bin/env bash

# Print message in terminal and log for the Console application.
function msg() {
    echo "$1"
    syslog -s -l alert "KA-Lite: $1"
}

PYTHON_VERSION=$(python -c 'import platform; print(platform.python_version())')
KALITE_REQ_PYTHON='2.7.11'

msg "Checking Python version."

# REF: http://stackoverflow.com/questions/6141581/detect-python-version-in-shell-script
# REF: http://www.tldp.org/LDP/abs/html/comparison-ops.html

if [ "${PYTHON_VERSION//.}" -lt "${KALITE_REQ_PYTHON//.}" ] || [ "${PYTHON_VERSION//.}" -ge "3000" ]; then
    msg "Installed Python version $PYTHON_VERSION"
    msg "You need to upgrade Python version from $PYTHON_VERSION to $KALITE_REQ_PYTHON+"
    exit 1
fi

msg "installed Pyhton version $PYTHON_VERSION."
exit 0