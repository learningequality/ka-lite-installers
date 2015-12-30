#!/bin/bash
#
# Notes: 
#    * This script must be run as root.  If ran as a standard user, it will prompt for the admin password.
#    * The files that will be removed, will be displayed on the console log.
#    * The $SCRIPT_NAME env variables was specified by the `Packages`.
#    * This is re-used as /Applications/KA-Lite/KA_Lite_Uninstall.tool during installation.
#
# What does this script do?
#    1. Unset the environment variables: KALITE_PYTHON and KALITE_HOME.
#    2. Remove the .plist file, kalite executable and the ka-lite resources.
#    3. When run stand-alone, it confirms removal of the KA Lite data directory as specified by the KALITE_HOME env var.
#    3. Display a console log for this process.
#
# Some References:
# * http://stackoverflow.com/a/2264537/845481 - Converting string to lower case in Bash shell scripting
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
            echo "Now removing: ${file}"
            syslog -s -l error "Now removing: ${file}"
        fi
    done

    # Collect the directories and files to remove
    if [ "$SCRIPT_NAME" != "preinstall" ]; then
        # This script is not run by the Packages module.
        # Use AppleScript so we can use a graphical `sudo` prompt.
        # This way, people can enter the username they wish to use
        # for sudo, and it is more Apple-like.
        osascript -e "do shell script \"/bin/rm -Rf ${REMOVE_FILES_ARRAY[*]}\" with administrator privileges"
    else
        # This script is being run by the Packages module.
        sudo rm -Rf ${REMOVE_FILES_ARRAY[*]}
    fi

    # Verify that the uninstall succeeded by checking whether every file/folder
    # we meant to remove was actually removed.
    for file in "${REMOVE_FILES_ARRAY[@]}"; do
        if [ -e "${file}" ]; then
            echo "An error must have occurred since a file/folder that was supposed to be"
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
    echo -n "Do you wish to uninstall KA-Lite (Yes/No)? "
    read uninstall
    # convert answer to lowercase
    uninstall="$(echo $uninstall | tr '[:upper:]' '[:lower:]')"
    if [ "$uninstall" != "yes" ]; then
        echo "Aborting uninstall. (answer: ${uninstall})"
        key_exit 1
    fi

    # Check that KALITE_HOME env var exists, if not, assign it a default value.
    if [ -z ${KALITE_HOME+0} ]; then 
      KALITE_HOME="$HOME/.kalite/"
    fi

    echo
    echo "The $KALITE_HOME is the directory where the data files are located."
    echo -n "Do you want this directory to be deleted (Yes/No)? "
    read remove_kalite
    # convert answer to lowercase
    remove_kalite="$(echo $remove_kalite | tr '[:upper:]' '[:lower:]')"
    if [ "$remove_kalite" == "yes" ]; then
        append REMOVE_FILES_ARRAY "$KALITE_HOME"
        echo "Removing $KALITE_HOME directory (answer: ${remove_kalite})"
    else
        echo "NOT Removing $KALITE_HOME directory."
    fi

    echo "Unsetting the KALITE_HOME environment variable..."
    unset KALITE_HOME
    launchctl unsetenv KALITE_HOME
fi

echo "Unsetting the KALITE_PYTHON environment variable..."
unset KALITE_PYTHON
launchctl unsetenv KALITE_PYTHON

echo "Removing files..."
remove_files_initiator

echo "Done!"