#!/bin/bash


# Notes: 
#    * This script must be run as root.
#    * The console log will display the files that the user want to remove.
#    * The $SCRIPT_NAME env variable is specify by the `Packages`.
#
# What does this script do?
#    1. Unset environment variable: KALITE_PYTHON.
#    2. Remove the .plist file, kalite executable and ka-lite resources.
#    3. Check if the .plist file, kalite executable and ka-lite resources.
#    4. Display a console log for this process.
#    5. This script can be use as uninstaller.
#

#----------------------------------------------------------------------
# Global Variables
#----------------------------------------------------------------------
KALITE_MONITOR="/Applications/KA-Lite-Monitor.app"
KALITE="kalite"
KALITE_PLIST="org.learningequality.kalite.plist"
HOME_LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
ROOT_LAUNCH_AGENTS="/Library/LaunchAgents"
KALITE_EXECUTABLE_PATH="$(which $KALITE)"
KALITE_RESOURCES="/Users/Shared/ka-lite"
KALITE_USR_BIN_PATH="/usr/bin"
KALITE_USR_LOCAL_BIN_PATH="/usr/local/bin"
KALITE_UNINSTALL_SCRIPT="KA-Lite_Uninstall.tool"

REMOVE_FILES_ARRAY=()

#----------------------------------------------------------------------
# Functions
#----------------------------------------------------------------------
# @param [Integer] $1 exit code.
function key_exit() {
    echo "Press any key to exit."
    read
    exit $1
}

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
    if [ "$SCRIPT_NAME" != "preinstall" ]; then
        # If this script is not run by packages.
        # Use AppleScript so we can use a graphical `sudo` prompt.
        # This way, people can enter the username they wish to use
        # for sudo, and it is more Apple-like.
        osascript -e "do shell script \"/bin/rm -Rf ${REMOVE_FILES_ARRAY[*]}\" with administrator privileges"
    else
        # If this script is run by packages.
        sudo rm -Rf ${REMOVE_FILES_ARRAY[*]}
    fi

    # Verify that the uninstall succeeded by checking whether every file
    # we meant to remove is actually removed.
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

#----------------------------------------------------------------------
# Script
#----------------------------------------------------------------------
ENV=$(env)
syslog -s -l error "Packages pre-installation initialize with env:'\n'$ENV" 

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

# Collect the directories and files to remove
test -d /Applications/KA-Lite                   && REMOVE_FILES_ARRAY+=("/Applications/KA-Lite")
test -f $SCRIPTPATH/$KALITE_UNINSTALL_SCRIPT    && REMOVE_FILES_ARRAY+=("$SCRIPTPATH/$KALITE_UNINSTALL_SCRIPT")
test -d $KALITE_RESOURCES                       && REMOVE_FILES_ARRAY+=("$KALITE_RESOURCES")
test -f $KALITE_USR_LOCAL_BIN_PATH/$KALITE      && REMOVE_FILES_ARRAY+=("$KALITE_USR_LOCAL_BIN_PATH/$KALITE")
test -f $KALITE_USR_BIN_PATH/$KALITE            && REMOVE_FILES_ARRAY+=("$KALITE_USR_BIN_PATH/$KALITE")
test -d $KALITE_MONITOR                         && REMOVE_FILES_ARRAY+=("$KALITE_MONITOR")

if [ "$SCRIPT_NAME" != "preinstall" ]; then
    # Introduction 
    echo "                                                          "
    echo "   _   __  ___    _     _ _                               "
    echo "  | | / / / _ \  | |   (_) |                              "
    echo "  | |/ / / /_\ \ | |    _| |_ ___                         "
    echo "  |    \ |  _  | | |   | | __/ _ \                        "
    echo "  | |\  \| | | | | |___| | ||  __/                        "
    echo "  \_| \_/\_| |_/ \_____/_|\__\___| Uninstall              "
    echo "                                                          "
    echo "https://learningequality.org/ka-lite/                     "
    echo "                                                          "
    echo "     version 0.16.x                                       "
    echo "                                                          "

fi

for root_plist in $ROOT_LAUNCH_AGENTS/org.learningequality.*.plist; do
    append REMOVE_FILES_ARRAY $root_plist
done

for home_plist in $HOME_LAUNCH_AGENTS/org.learningequality.*.plist; do
    append REMOVE_FILES_ARRAY $home_plist
done

# Print the files and directories that are to be removed and verify
# with the user that that is what he/she really wants to do.
echo "The following files and directories will be removed:"
for file in "${REMOVE_FILES_ARRAY[@]}"; do
    echo "    $file"
done

if [ "$SCRIPT_NAME" != "preinstall" ]; then

    if [ -d "$SCRIPTPATH/KA-Lite.app" ] && [ -f "$SCRIPTPATH/$KALITE_UNINSTALL_SCRIPT" ]; then
        append REMOVE_FILES_ARRAY $SCRIPTPATH
    fi

    echo "         "
    echo "Do you wish to uninstall KA-Lite (Yes/No)?"
    read user_input
    if test "$user_input" != "Yes"  -a  "$user_input" != "YES"  -a  "$user_input" != "yes"; then
        echo "Aborting install. (answer: ${user_input})"
        key_exit 1
    fi

    # Check KALITE_HOME exists if not assign a default value for it.
    if [ -z ${KALITE_HOME+0} ]; then 
      KALITE_HOME="$HOME/.kalite"
    fi

    echo "The $KALITE_HOME is the directory where the data files are located."
    echo "Do you want this directory to be deleted (Yes/No)?"
    read user_input2
    if test "$user_input2" == "Yes"  -a  "$user_input2" == "YES"  -a  "$user_input2" == "yes"; then
        append REMOVE_FILES_ARRAY $KALITE_HOME
        echo "Removing $KALITE_HOME directory (answer: ${user_input2})"
    fi

    echo "Unset the KALITE_HOME environment variable"
    launchctl unsetenv KALITE_HOME
fi

echo "Unset the KALITE_PYTHON environment variable"
launchctl unsetenv KALITE_PYTHON

echo "Removing files..."
remove_files_initiator

echo "Done!"