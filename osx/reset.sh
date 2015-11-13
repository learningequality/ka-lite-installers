#!/bin/bash

#  This will remove the following.
#    1. Unset environment variable: KALITE_PYTHON
#    2. remove the .plist file, need admin
#    3. delete the symlinked /usr/bin/kalite command, need admin

KALITE_PLIST="org.learningequality.kalite.plist"
TEMP="/tmp"
LIBRARY="/Library/LaunchAgents"
KALITE_EXECUTABLE_PATH="$(which kalite)"


# Delete the .plist file.
if [ -f "$TEMP/$KALITE_PLIST" ]; then
    echo "Removing $TEMP/$KALITE_PLIST "
    sudo rm "$TEMP/$KALITE_PLIST"
else
    echo "$KALITE_PLIST not found. "
fi

if [ -f "$LIBRARY/$KALITE_PLIST" ]; then
    echo "Removing $LIBRARY/$KALITE_PLIST "
    sudo rm "$LIBRARY/$KALITE_PLIST"
else
    echo "$LIBRARY/$KALITE_PLIST not found."
fi

# Delete the symlinked `kalite` executable.
# REF: http://stackoverflow.com/questions/21799441/test-if-executable-exists-in-unix
if which kalite > /dev/null 2>&1; then
    echo "Removing $KALITE_EXECUTABLE_PATH "
    sudo rm $KALITE_EXECUTABLE_PATH
else
    echo "kalite executable not found. "
fi

# remove KALITE_PYTHON environment variable
echo "Unset the KALITE_PYTHON environment variable "
launchctl unsetenv KALITE_PYTHON
