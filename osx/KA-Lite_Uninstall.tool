#!/usr/bin/env bash

# Override any funny stuff from the user.
export PATH="/bin:/usr/bin:/sbin:/usr/sbin:$PATH"

#----------------------------------------------------------------------
# Global Variables
#----------------------------------------------------------------------
KALITE_MONITOR_APP="/Applications/KA-Lite-Monitor.app"
KALITE_APP="/Applications/KA-Lite/KA-Lite.app"
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
        fi
    done

    # Initiate the actual uninstall, which requires admin privileges.
    echo "The uninstallation process requires administrative privileges"
    echo "because some of the installed files cannot be removed by a"
    echo "normal user. You will be prompted for a password..."
    echo ""

    # Use AppleScript so we can use a graphical `sudo` prompt.
    # This way, people can enter the username they wish to use
    # for sudo, and it is more Apple-like.

    osascript -e "do shell script \"/bin/rm -Rf ${REMOVE_FILES_ARRAY[*]}\" with administrator privileges"

    # Verify that the uninstall succeeded by checking whether every file
    # we meant to remove is actually removed.
    for file in "${REMOVE_FILES_ARRAY[@]}"; do
        if [ -e "${file}" ]; then
            echo "An error must have occurred since a file that was supposed to be"
            echo "removed still exists: ${file}"
            echo ""
            echo "Please try again."
            key_exit 1
        fi
    done
}

#----------------------------------------------------------------------
# Script
#----------------------------------------------------------------------
# Delete specific location where the kalite is installed.
# Reliable way for a bash script to get the full path to itself?
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

# Collect the directories and files to remove
REMOVE_FILES_ARRAY=()

test -d /Applications/KA-Lite                   && REMOVE_FILES_ARRAY+=("/Applications/KA-Lite")
test -f $SCRIPTPATH/KA-Lite_Uninstall.tool      && REMOVE_FILES_ARRAY+=("$SCRIPTPATH/KA-Lite_Uninstall.tool")

test -d $KALITE_RESOURCES                       && REMOVE_FILES_ARRAY+=("$KALITE_RESOURCES")
test -f $HOME_LAUNCH_AGENTS/$KALITE_PLIST       && REMOVE_FILES_ARRAY+=("$HOME_LAUNCH_AGENTS/$KALITE_PLIST")
test -f $ROOT_LAUNCH_AGENTS/$KALITE_PLIST       && REMOVE_FILES_ARRAY+=("$ROOT_LAUNCH_AGENTS/$KALITE_PLIST")
test -f $KALITE_MONITOR_APP                     && REMOVE_FILES_ARRAY+=("$KALITE_MONITOR_APP")
test -f $KALITE_USR_BIN_PATH/$KALITE            && REMOVE_FILES_ARRAY+=("$KALITE_USR_BIN_PATH/$KALITE")
test -f $KALITE_USR_LOCAL_BIN_PATH/$KALITE      && REMOVE_FILES_ARRAY+=("$KALITE_USR_LOCAL_BIN_PATH/$KALITE")

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


# Print the files and directories that are to be removed and verify
# with the user that that is what he/she really wants to do.

# if [ "$SCRIPTPATH" != "/Applications/KA-Lite" ]; then
if [ -d "$SCRIPTPATH/KA-Lite.app" ] && [ -f "$SCRIPTPATH/KA-Lite_Uninstall.tool" ]; then
    REMOVE_FILES_ARRAY+=("$SCRIPTPATH")
fi

echo "The following files and directories will be removed:"
for file in "${REMOVE_FILES_ARRAY[@]}"; do
    echo "    $file"
done

echo "Do you wish to uninstall KA-Lite (y/n)?"
read user_input
if [ "$user_input" != "y" ]; then
    echo "Aborting install. (answer: ${user_input})"
    key_exit 2
fi

echo "Do you want to remove the .kalite directory (y/n)?"
read user_input2
if [ "$user_input2" == "y" ]; then
    append REMOVE_FILES_ARRAY "~/.kalite/"
    echo "Removing .kalite directory (answer: ${user_input2})"
fi

echo "Unset the KALITE_PYTHON environment variable"
launchctl unsetenv KALITE_PYTHON


echo "Unset the KALITE_HOME environment variable"
launchctl unsetenv KALITE_HOME

echo "Removing files..."
remove_files_initiator

echo "Successfully uninstalled KA-Lite."
key_exit 0
