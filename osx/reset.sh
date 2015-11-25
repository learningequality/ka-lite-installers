#!/bin/bash

#  This will remove the following.
#    1. Unset environment variable: KALITE_PYTHON
#    2. Remove the .plist file, need admin
#    3. Delete kalite executable symlinked.

KALITE_PLIST="org.learningequality.kalite.plist"
TEMP="/tmp"
LIBRARY="/Library/LaunchAgents"
TEMP_PLIST="$TEMP/$KALITE_PLIST"
LIBRARY_PLIST="$LIBRARY/$KALITE_PLIST"
KALITE_EXECUTABLE_PATH="$(which kalite)"
KALITE_SOURCE="/Users/Shared/ka-lite"


# Delete the .plist file.
if [ -f $TEMP_PLIST ]; then
    echo "Removing $TEMP_PLIST"
    sudo rm $TEMP_PLIST
else
    echo "$TEMP_PLIST not found."
fi

if [ -f $LIBRARY_PLIST ]; then
    echo "Removing $LIBRARY_PLIST"
    sudo rm $LIBRARY_PLIST
else
    echo "$LIBRARY_PLIST not found."
fi

# Delete the symlinked `kalite` executable.
# REF: http://stackoverflow.com/questions/21799441/test-if-executable-exists-in-unix
if which kalite > /dev/null 2>&1; then
    echo "Removing $KALITE_EXECUTABLE_PATH "
    sudo rm $KALITE_EXECUTABLE_PATH
else
    echo "kalite executable not found."
fi

# Removing $KALITE_SOURCE
if [ -d "$KALITE_SOURCE" ]; then
	echo "Removing '$KALITE_SOURCE'..."
	rm -fr $KALITE_SOURCE
	if [ $? -ne 0 ]; then
    	echo ".. Abort!  Error encountered removing '$KALITE_SOURCE'."
    	exit 1
	fi
fi

# remove KALITE_PYTHON environment variable
echo "Unset the KALITE_PYTHON environment variable"
launchctl unsetenv KALITE_PYTHON
