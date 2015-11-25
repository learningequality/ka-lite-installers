#!/usr/bin/env bash

# Packages postscript for KA-Lite
#
# Steps
# 1. Symlink kalite executable  to /usr/local/bin.
# 2. Export KALITE_PYTHON env that point to Pyrun directory.
# 3. Create plist in ~/Library/LaunchAgents folders.
# 4. Run shebangcheck that check the BIN_PATH that points to the python/pyrun interpreter to use.
# 5. Run kalite manage syncdb --noinput.
# 6. Run kalite manage init_content_items --overwrite.
# 7. Run kalite manage setup --noinput.
# 8. Run kalite manage unpack_assessment_zip <assessment_path>.
# 9. Change the owner of a $HOME/.kalite.

# Note: This script always run on sudo.

#----------------------------------------------------------------------
# Global Variables
#----------------------------------------------------------------------
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

KALITE_SHARED="/Users/Shared/ka-lite"
KALITE_DIR="$HOME/.kalite"
PYRUN_NAME="pyrun-2.7"
PYRUN_DIR="$KALITE_SHARED/$PYRUN_NAME"
PYRUN="$PYRUN_DIR/bin/pyrun"
PYRUN_PIP="$PYRUN_DIR/bin/pip"
BIN_PATH="$PYRUN_DIR/bin"
ASSESSMENT_SRC="$KALITE_SHARED/assessment/assessment.zip"
SHEBANGCHECK_PATH="$KALITE_SHARED/scripts/"

SYMLINK_FILE="$KALITE_SHARED/pyrun-2.7/bin/kalite"
SYMLINK_TO="/usr/bin"
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

ENV=$(env)
syslog -s -l error "Packages post-installation initialize with env:'\n'$ENV" 

STEP=1
STEPS=9

echo "Now preparing KA-Lite dependencies..."

echo "$STEP/$STEPS. Symlink kalite executable to /usr/local/bin..."
if [ ! -d "$SYMLINK_TO" ]; then
    echo ".. Now creating '$SYMLINK_TO'..."
    sudo mkdir -p $SYMLINK_TO
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Error encountered creating '$SYMLINK_TO' directory."
        exit 1
    fi
fi


if [ -f "$KALITE" ]; then
    echo ".. Found $KALITE executable, it will be removed and will create new one."
    rm -fr $KALITE
fi


$COMMAND_SYMLINK
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error encountered running '$COMMAND_SYMLINK'."
    exit 1
fi

((STEP++))
echo "$STEP/$STEPS. Export KALITE_PYTHON env that point to Pyrun directory..."
update_env

((STEP++))
echo "$STEP/$STEPS. Create plist in ~/Library/LaunchAgents folders..."
if [ -f "$PLIST_SRC" ]; then
    echo ".. Found an existing '$PLIST_SRC', now removing it."
    rm -fr $PLIST_SRC
fi


if [ ! -d "$LAUNCH_AGENTS" ]; then
    echo ".. Now creating '$LAUNCH_AGENTS'..."
    sudo mkdir -p $LAUNCH_AGENTS
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Error encountered creating '$LAUNCH_AGENTS' directory."
        exit 1
    fi
fi

create_plist

((STEP++))
echo "$STEP/$STEPS. check the BIN_PATH that points to the python/pyrun interpreter to use..."
$PYRUN $SHEBANGCHECK_PATH/shebangcheck.py
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error encountered running '$SHEBANGCHECK_PATH/shebangcheck.py'."
    exit 1
fi

((STEP++))
echo "$STEP/$STEPS. Running kalite manage syncdb --noinput..."
$BIN_PATH/kalite manage syncdb --noinput

((STEP++))
echo "$STEP/$STEPS. Running kalite manage init_content_items --overwrite..."
$BIN_PATH/kalite manage init_content_items --overwrite

((STEP++))
echo "$STEP/$STEPS. Running kalite manage setup --noinput..."
$BIN_PATH/kalite manage setup --noinput

((STEP++))
echo "$STEP/$STEPS. Running kalite manage unpack_assessment_zip '$ASSESSMENT_SRC'..."
$BIN_PATH/kalite manage unpack_assessment_zip $ASSESSMENT_SRC    


((STEP++))
echo "$STEP/$STEPS. Changing the owner of the '$KALITE_DIR'..."
chown -R $USER:$SUDO_GID $KALITE_DIR
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error changing permission on '$KALITE_DIR'."
    exit 1
fi

echo "Done!"
