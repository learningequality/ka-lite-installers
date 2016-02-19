#!/bin/bash
# 
# Arguments:
#   * $1 - Optional, used for the confirmation of the uninstall process.  Pass "yes" to auto-confirm the uninstall process, "no" will cancel the process.  If not passed, it will confirm the action with the user.
#   * $2 - Optional, used for the deletion of the KA Lite data folder.  Pass "yes" to auto-confirm, "no" will not delete it.  If not passed, it will confirm the action with the user.
#
# Notes: 
#   * This script must be run as root.  If ran as a standard user, it will prompt for the admin password.
#   * The files that will be removed, will be displayed in the Console application.
#   * The $SCRIPT_NAME env variables was specified by the `Packages`.
#   * This is re-used as /Applications/KA-Lite/KA_Lite_Uninstall.tool during installation.
#
# What does this script do?
#   1. Unset the environment variables: KALITE_PYTHON and KALITE_HOME.
#   2. Remove the .plist file, kalite executable and the ka-lite resources.
#   3. When run stand-alone, it confirms removal of the KA-Lite data directory as specified by the KALITE_HOME env var.
#   4. Display a console log for this process.
#
# Some References:
#   * http://stackoverflow.com/a/2264537/845481 - Converting string to lower case in Bash shell scripting
#

#----------------------------------------------------------------------
# Global Variables
#----------------------------------------------------------------------
IS_PREINSTALL=false
if [ "$SCRIPT_NAME" == "preinstall" ]; then
    IS_PREINSTALL=true
fi
echo "IS_PREINSTALL == $IS_PREINSTALL"

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


# This function will check if the files or folders exists.
function check_files() {
    uninstall_count=0
    for file in "${REMOVE_FILES_ARRAY[@]}"; do
        if [ -e "${file}" ]; then
            ((uninstall_count++))
        fi
    done
    if [ $uninstall_count -eq 0 ]; then
        echo
        echo "Cannot find any KA-Lite files or folders, nothing to uninstall here."
        return 1
    fi
    return 0
}


# This function will remove the files or folders.
function remove_files_initiator {

    uninstall_count=0
    for file in "${REMOVE_FILES_ARRAY[@]}"; do
        if [ -e "${file}" ]; then
            msg "Will remove: ${file}"
            ((uninstall_count++))
        fi
    done
    if [ $uninstall_count -eq 0 ]; then
        echo
        echo "Cannot find any KA-Lite files or folders, nothing to uninstall here."
        exit
    fi

    # Collect the directories and files to remove
    if [ $IS_PREINSTALL == false ]; then
        # This script is not run by the Packages module.
        # Use AppleScript so we can use a graphical `sudo` prompt.
        # This way, people can enter the username they wish to use
        # for sudo, and it is more Apple-like.
        osascript -e "do shell script \"/bin/rm -Rf ${REMOVE_FILES_ARRAY[*]}\" with administrator privileges"
    else
        # This script is being run by the Packages module.
        sudo rm -Rf ${REMOVE_FILES_ARRAY[*]}
    fi
    # If process did not succeed, let's return non-zero.
    if [ $? -ne 0 ]; then
        msg "Uninstall process cancelled."
        exit 1
    fi
}


function msg() {
    echo "$1"
    syslog -s -l alert "KA-Lite: $1"
}


#----------------------------------------------------------------------
# Script
#----------------------------------------------------------------------
# ENV=$(env)
# syslog -s -l alert "Packages pre-installation initialize with env:'\n'$ENV" 

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

if [ $IS_PREINSTALL == false ]; then
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
    if [ -e $root_plist ]; then
        append REMOVE_FILES_ARRAY $root_plist
    fi
done

for home_plist in $HOME_LAUNCH_AGENTS/org.learningequality.*.plist; do
    if [ -e $home_plist ]; then
        append REMOVE_FILES_ARRAY $home_plist
    fi
done

if [ $IS_PREINSTALL == false ]; then
    # Check that KALITE_HOME env var exists, if not, assign it a default value.
    if [ -z ${KALITE_HOME+0} ]; then 
      KALITE_HOME="$HOME/.kalite/"
    fi

    # Check if the directory exists before confirming to include it on the list.
    if [ -d "$KALITE_HOME" ]; then
        echo "The KALITE_HOME environment variable points to $KALITE_HOME."
        echo "This is the directory where the data files are located."
        echo "Answer no if you want to keep your KA-Lite data files."
        echo
        echo -n "Do you want the $KALITE_HOME directory to be deleted? (Yes/No) "
        # Check if the second argument has a value. 
        remove_kalite="$(echo $2 | tr '[:upper:]' '[:lower:]')"
        if [ "$remove_kalite" == "yes" ]; then
            msg "Auto confirm removing the $KALITE_HOME directory."
        elif [ "$remove_kalite" == "no" ]; then
            msg "NOT Removing $KALITE_HOME directory."
        else
            read remove_kalite
            # convert answer to lowercase
            remove_kalite="$(echo $remove_kalite | tr '[:upper:]' '[:lower:]')"
        fi
        if [ "$remove_kalite" == "yes" ]; then
            append REMOVE_FILES_ARRAY "$KALITE_HOME"
            echo "Will remove $KALITE_HOME directory."
        else
            echo "NOT Removing $KALITE_HOME directory."
        fi

    else
        msg "The $KALITE_HOME directory does not exist, so there are no KA-Lite data files to delete."
    fi

    # MUST: Check that the KA-Lite app and the uninstall script exists inside the SCRIPTPATH
    # before adding the folder to the to-be-deleted list.  This will make sure we don't 
    # accidentally delete the folder containing this script.
    if [ -d "$SCRIPTPATH/KA-Lite.app" ] && [ -f "$SCRIPTPATH/$KALITE_UNINSTALL_SCRIPT" ]; then
        append REMOVE_FILES_ARRAY $SCRIPTPATH
    fi
fi

# Done getting files/folders to remove, check if we actually have files to remove.
check_files
if [ $? -ne 0 ]; then
    exit
fi

# Print the files and directories that well be removed and verify
# with the user.
echo
echo "The following files/directories will be removed:"
for file in "${REMOVE_FILES_ARRAY[@]}"; do
    echo "    $file"
done

echo
echo "And then the following environment variables will be unset:"
echo "  KALITE_PYTHON with value $KALITE_PYTHON"
echo "  KALITE_HOME with value $KALITE_HOME"

if [ $IS_PREINSTALL == false ]; then
    echo "         "
    echo -n "Do you wish to uninstall KA-Lite? (Yes/No) "
    # Check if the first argument has a value. 
    uninstall="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
    if [ "$uninstall" == "yes" ]; then
        msg "Auto confirm uninstallation process."
    elif [ "$uninstall" == "no" ]; then
        msg "NOT proceeding with the uninstall process."
    else
        read uninstall
        # convert answer to lowercase
        uninstall="$(echo $uninstall | tr '[:upper:]' '[:lower:]')"
    fi
    if [ "$uninstall" != "yes" ]; then
        echo "Aborting uninstall. (answer: ${uninstall})"
        key_exit 1
    fi
fi

echo "Removing files..."
# This function will prompt for the admin password which is the 
# last chance to cancel the uninstall process.
remove_files_initiator
if [ $? -ne 0 ]; then
    msg "Uninstall process cancelled."
    exit 1
fi

msg "Unsetting the KALITE_PYTHON environment variable..."
unset KALITE_PYTHON
launchctl unsetenv KALITE_PYTHON

msg "Unsetting the KALITE_HOME environment variable..."
unset KALITE_HOME
launchctl unsetenv KALITE_HOME

msg "Done! KA Lite is now uninstalled."
