#!/usr/bin/env bash


# Global Variables
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

KALITE_SHARED="/Users/Shared/ka-lite"
KALITE_DIR="~/.kalite/"
PYRUN_NAME="pyrun-2.7"
PYRUN_DIR="$KALITE_SHARED/$PYRUN_NAME"
PYRUN="$PYRUN_DIR/bin/pyrun"
PYRUN_PIP="$PYRUN_DIR/bin/pip"
BIN_PATH="$PYRUN_DIR/bin"
ASSESSMENT_SRC="$KALITE_SHARED/assessment/assessment.zip"
SHEBANGCHECK_PATH="$KALITE_SHARED/scripts/"

SYMLINK_FILE="$KALITE_SHARED/pyrun-2.7/bin/kalite"
SYMLINK_TO="/usr/local/bin"
COMMAND_SYMLINK="ln -sf $SYMLINK_FILE $SYMLINK_TO"

ORG="org.learningequality.kalite"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents/"
KALITE=$(which kalite)
PLIST_SRC="$LAUNCH_AGENTS$ORG.plist"


#----------------------------------------------------------------------
# Functions
#----------------------------------------------------------------------
function update_env {
    # MUST: Make sure we have a KALITE_PYTHON env var that points to Pyrun
    echo "Updating KALITE_PYTHON environment variable..."
    launchctl setenv  KALITE_PYTHON "$PYRUN"
    export KALITE_PYTHON="$PYRUN"
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Error/s encountered exporting KALITE_PYTHON '$PYRUN'."
        exit 1
    fi
}

function create_plist {
    # Create Plist 
    echo "Now creating '$PLIST_SRC'..."
    echo "<?xml version='1.0' encoding='UTF-8'?>" >> $PLIST_SRC
    echo "<!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'>" >> $PLIST_SRC
    echo "<plist version='1.0'>" >> $PLIST_SRC
    echo "<dict>" >> $PLIST_SRC
    echo -e "\t<key>Label</key>" >> $PLIST_SRC
    echo -e "\t<string>org.learningequality.kalite</string>" >> $PLIST_SRC
    echo -e "\t<key>ProgramArguments</key>" >> $PLIST_SRC
    echo -e "\t<array>" >> $PLIST_SRC
    echo -e "\t\t<string>sh</string>" >> $PLIST_SRC
    echo -e "\t\t<string>-c</string>" >> $PLIST_SRC
    echo -e "\t\t<string>launchctl setenv KALITE_PYTHON \"$PYRUN\"</string>" >> $PLIST_SRC
    echo -e "\t</array>" >> $PLIST_SRC
    echo -e "\t<key>RunAtLoad</key>" >> $PLIST_SRC
    echo -e "\t<true/>" >> $PLIST_SRC
    echo "</dict>" >> $PLIST_SRC
    echo "</plist>" >> $PLIST_SRC
}

#----------------------------------------------------------------------
# Script
#----------------------------------------------------------------------
echo "Now preparing KA-Lite dependencies..."

# Create $SYMLINK_TO directory should used sudo
if [ ! -d "$SYMLINK_TO" ]; then
    echo ".. Now creating '$SYMLINK_TO'..."
    sudo mkdir -p $SYMLINK_TO
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Error encountered creating '$SYMLINK_TO' directory."
        exit 1
    fi
fi

# Symlink kalite executable to /usr/local/bin
if [ -f "$KALITE" ]; then
    echo ".. Found $KALITE executable, it will be removed and will create new one."
    rm -fr $KALITE
fi


$COMMAND_SYMLINK
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error encountered running '$COMMAND_SYMLINK'."
    exit 1
fi


update_env
# Create plist in ~/Library/LaunchAgents folders.
if [ -f "$PLIST_SRC" ]; then
    echo ".. Found an existing '$PLIST_SRC', now removing it."
    rm -fr $PLIST_SRC
fi


# Create $LAUNCH_AGENTS directory should used sudo
if [ ! -d "$LAUNCH_AGENTS" ]; then
    echo ".. Now creating '$LAUNCH_AGENTS'..."
    sudo mkdir -p $LAUNCH_AGENTS
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Error encountered creating '$LAUNCH_AGENTS' directory."
        exit 1
    fi
fi

create_plist

$PYRUN $SHEBANGCHECK_PATH/shebangcheck.py
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error encountered running '$SHEBANGCHECK_PATH/shebangcheck.py'."
    exit 1
fi

export KALITE_PYTHON="$PYRUN"
echo "Running manage syncdb..."
$BIN_PATH/kalite manage syncdb --noinput


echo "Running manage setup..."
$BIN_PATH/kalite manage setup --noinput

echo "Unpacking assessment.zip..."
$BIN_PATH/kalite manage unpack_assessment_zip $ASSESSMENT_SRC


