#!/usr/bin/env bash


# Global Variables
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

KALITE_SHARED="/Users/Shared/ka-lite"
KALITE_DIR="~/.kalite"

PYRUN_NAME="pyrun-2.7"
PYRUN_DIR="$KALITE_SHARED/$PYRUN_NAME"
PYRUN="$PYRUN_DIR/bin/pyrun"
PYRUN_PIP="$PYRUN_DIR/bin/pip"
BIN_PATH="$PYRUN_DIR/bin"
ASSESSMENT_SRC="$KALITE_SHARED/assessment/assessment.zip"
KALITE_SCRIPT="$KALITE_SHARED/scripts"

SYMLINK_FILE="$KALITE_SHARED/pyrun-2.7/bin/kalite"
SYMLINK_TO="/usr/local/bin"
COMMAND_SYMLINK="ln -s $SYMLINK_FILE $SYMLINK_TO"

TMP="/tmp/"
ORG="org.learningequality.kalite"
LAUNCH_AGENTS="~/Library/LaunchAgents/"
KALITE=$(which kalite)
PLIST_SRC="$TMP$ORG.plist"
PLIST_DST"$LAUNCH_AGENTS$ORG.plist"


#----------------------------------------------------------------------
# Functions
#----------------------------------------------------------------------
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
echo "Now exporting KALITE_PYTHON '$PYRUN'..."
export KALITE_PYTHON="$PYRUN"

echo "Removing all permission on $KALITE_SHARED..."
chmod -R 777 $KALITE_SHARED
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error encountered removing all permission on '$KALITE_SCRIPT/set_env.sh'."
    exit 1
fi

echo "Running set_env.sh..."
bash $KALITE_SCRIPT/set_env.sh
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error encountered running '$KALITE_SCRIPT/set_env.sh'."
    exit 1
fi

echo "Now preparing KA-Lite dependencies..."
# Symlink kalite executable to /usr/local/bin
if [ -f "$KALITE" ]; then
    echo ".. Found $KALITE executable, it will be removed and will create new one."
    rm -fr $KALITE
fi
$COMMAND_SYMLINK
if [ $? -ne 0 ]; then
    exit 1
fi

# Create plist in /tmp and /Library/LaunchAgents folders.
if [ -f "$PLIST_SRC" ]; then
    echo ".. Found an existing '$PLIST_SRC', now removing it."
    rm -fr $PLIST_SRC
    rm -fr $PLIST_DST
fi
create_plist
cp -fr $PLIST_SRC $PLIST_DST

$PYRUN $KALITE_SCRIPT/shebangcheck.py
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error encountered running '$KALITE_SCRIPT/shebangcheck.py'."
    exit 1
fi

echo "Running manage syncdb..."
kalite manage syncdb --noinput
if [ $? -ne 0 ]; then
    syslog -s -l error "Error encountered running kalite manage syncdb --noinput"
    # exit 1
fi
echo "Running manage setup..."
kalite manage setup --noinput
if [ $? -ne 0 ]; then
    syslog -s -l error "Error encountered running kalite manage setup --noinput"
    # TODO(eduard):  We encountered an error on kalite manage setup --noinput 
    # REF: https://github.com/learningequality/ka-lite/pull/4630#issuecomment-155562193
    # exit 1
fi

echo "Unpacking assessment.zip..."
kalite manage unpack_assessment_zip $ASSESSMENT_SRC
if [ $? -ne 0 ]; then
    syslog -s -l error "Error encountered running kalite manage unpack_assessment_zip '$ASSESSMENT_SRC'."
    # exit 1
fi

echo "Removing all permission on $KALITE_DIR"
if [ -f "$KALITE_DIR " ]; then
    chmod -R 777 $KALITE_DIR
fi







