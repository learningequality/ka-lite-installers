#!/usr/bin/env bash

# @param [Integer] $1 exit code.
function key_exit() {
    echo "Press any key to exit."
    read
    exit $1
}

# Appends a value to an array.
#
# @param [String] $1 Name of the variable to modify
# @param [String] $2 Value to append
function append() {
    eval $1[\${#$1[*]}]=$2
}


# Delete specific location where the kalite is installed.
# Reliable way for a bash script to get the full path to itself?
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

#----------------------------------------------------------------------
# Script
#----------------------------------------------------------------------
# Collect the directories and files to remove
KALITE_FILES=()
append KALITE_FILES "/Applications/KA-Lite"
append KALITE_FILES "/usr/bin/kalite"
append KALITE_FILES $SCRIPTPATH

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
echo "Do you wish to uninstall KA-Lite (y/n)?"
read user_input
if [ "$user_input" != "y" ]; then
    echo "Aborting install. (answer: ${user_input})"
    key_exit 2
fi

echo "Do you want to remove the .kalite directory (y/n)?"
read user_input2
if [ "$user_input2" == "y" ]; then
    append KALITE_FILES "~/.kalite/"
    echo "Removing .kalite directory (answer: ${user_input2})"
fi

echo "The following files and directories will be removed:"
for file in "${KALITE_FILES[@]}"; do
    echo "    $file"
done

 
# Initiate the actual uninstall, which requires admin privileges.
echo "The uninstallation process requires administrative privileges"
echo "because some of the installed files cannot be removed by a"
echo "normal user. You will be prompted for a password..."
echo ""

# Use AppleScript so we can use a graphical `sudo` prompt.
# This way, people can enter the username they wish to use
# for sudo, and it is more Apple-like.

osascript -e "do shell script \"/bin/rm -Rf ${KALITE_FILES[*]}\" with administrator privileges"

# Verify that the uninstall succeeded by checking whether every file
# we meant to remove is actually removed.
for file in "${KALITE_FILES[@]}"; do
    if [ -e "${file}" ]; then
        echo "An error must have occurred since a file that was supposed to be"
        echo "removed still exists: ${file}"
        echo ""
        echo "Please try again."
        key_exit 1
    fi
done

echo "Successfully uninstalled KA-Lite."
key_exit 0
