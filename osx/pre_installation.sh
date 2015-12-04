#!/bin/bash


# Notes: 
#    * This script must be run as root.
#    * The files that will be removed, will be displayed on the console log.
#
# What does this script do?
#    1. Unset environment variable: KALITE_PYTHON.
#    2. Remove the .plist file, kalite executable and ka-lite resources.
#    3. Check if the .plist file, kalite executable and ka-lite resources.
#    4. Display a console log for this process.
#

#----------------------------------------------------------------------
# Global Variables
#----------------------------------------------------------------------
KALITE_MONITOR="/Applications/KA-Lite-Monitor.app"
KALITE="kalite"
KALITE_PLIST="org.learningequality.kalite.plist"
HOME_LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
ROOT_LAUNCH_AGENTS="/Library/LaunchAgents"
LIBRARY_PLIST="$LAUNCH_AGENTS/$KALITE_PLIST"
KALITE_EXECUTABLE_PATH="$(which $KALITE)"
KALITE_RESOURCES="/Users/Shared/ka-lite"
KALITE_USR_BIN_PATH="/usr/bin"
KALITE_USR_LOCAL_BIN_PATH="/usr/local/bin"

REMOVE_FILES_ARRAY=()

#----------------------------------------------------------------------
# Functions
#----------------------------------------------------------------------
function append() {
    eval $1[\${#$1[*]}]=$2
}


function remove_files_initiator {

    for file in "${REMOVE_FILES_ARRAY[@]}"; do
        if [ -e "${file}" ]; then
            echo "Now removing file: ${file}"
            syslog -s -l error "Now removing file: ${file}"
        fi
    done

    # Collect the directories and files to remove
    sudo rm -Rf ${REMOVE_FILES_ARRAY[*]}

    for file in "${REMOVE_FILES_ARRAY[@]}"; do
        if [ -e "${file}" ]; then
            echo "An error must have occurred since a file that was supposed to be"
            echo "removed still exists: ${file}"
            syslog -s -l error "File still exists: ${file}"
            echo ""
            exit 1
        fi
    done
}


function check_kalite_exc_collector {
    
    if which kalite > /dev/null 2>&1; then
        append REMOVE_FILES_ARRAY $KALITE_EXECUTABLE_PATH
    fi
    
    if [ -f "$KALITE_USR_BIN_PATH/$KALITE" ]; then
        append REMOVE_FILES_ARRAY $KALITE_USR_BIN_PATH/$KALITE
    else
        echo "'$KALITE_USR_BIN_PATH/$KALITE' executable not found."
        syslog -s -l error "'$KALITE_USR_BIN_PATH/$KALITE' executable not found."
    fi

    if [ -f "$KALITE_USR_LOCAL_BIN_PATH/$KALITE" ]; then
        append REMOVE_FILES_ARRAY $KALITE_USR_LOCAL_BIN_PATH/$KALITE
    else
        echo "'$KALITE_USR_LOCAL_BIN_PATH/$KALITE' executable not found."
        syslog -s -l error "'$KALITE_USR_BIN_PATH/$KALITE' executable not found."
    fi
    remove_files_initiator
}

#----------------------------------------------------------------------
# Script
#----------------------------------------------------------------------
ENV=$(env)
syslog -s -l error "Packages pre-installation initialize with env:'\n'$ENV" 

# Collect the directories and files to remove
append REMOVE_FILES_ARRAY $HOME_LAUNCH_AGENTS/$KALITE_PLIST
append REMOVE_FILES_ARRAY $ROOT_LAUNCH_AGENTS/$KALITE_PLIST
append REMOVE_FILES_ARRAY $KALITE_RESOURCES
append REMOVE_FILES_ARRAY $KALITE_MONITOR

echo "Unset the KALITE_PYTHON environment variable"
launchctl unsetenv KALITE_PYTHON

echo "Removing files..."
remove_files_initiator

echo "Check if the kalite executable is remove in '$KALITE_USR_BIN_PATH' and '$KALITE_USR_LOCAL_BIN_PATH'..."
check_kalite_exc_collector

echo "Done!"






