#!/usr/bin/env bash

echo "Now preparing KA-Lite dependencies.."

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

PYRUN_NAME="pyrun-2.7"
PYRUN_DIR="/Users/Shared/$PYRUN_NAME"
PYRUN="$PYRUN_DIR/bin/pyrun"
PYRUN_PIP="$PYRUN_DIR/bin/pip"
BIN_PATH="$PYRUN_DIR/bin"
ASSESSMENT_SRC="/Users/Shared/assessment/assessment.zip"
SHEBANGCHECK_PATH="/Users/Shared/scripts/"

SYMLINK_FILE="/Users/Shared/pyrun-2.7/bin/kalite"
SYMLINK_TO="/usr/local/bin"
COMMAND_SYMLINK="ln -s $SYMLINK_FILE $SYMLINK_TO"

TMP="/tmp/"
PLIST=".plist"
ORG="org.learningequality.kalite"
TARGET="/Library/LaunchAgents/"
KALITE=$(which kalite)

# Symlink kalite executable to /usr/local/bin
if [ -f "$KALITE" ]; then
    echo "$KALITE is already exist."
else
    $COMMAND_SYMLINK
fi

function update_env {
    echo "Updating KALITE_PYTHON environment variable"
    launchctl setenv  KALITE_PYTHON "$PYRUN"
    export KALITE_PYTHON="$PYRUN"
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Exporting KALITE_PYTHON '$KA_LITE_APP_PATH'."
        exit 1
    fi
}

if [ -z ${KALITE_PYTHON+0} ]; then
    update_env
else
    if [ "KALITE_PYTHON" != $PYRUN ]; then
        update_env
    fi
fi

$PYRUN $SHEBANGCHECK_PATH/shebangcheck.py
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$SHEBANGCHECK_PATH/shebangcheck.py'."
    exit 1
fi

# Create plist int /tmp and /Library/LaunchAgents folders.
if [ -f "$TMP$ORG$PLIST" ]; then
    echo "PLIST is already exist in $TMP"
else
    echo "<?xml version='1.0' encoding='UTF-8'?>" >> $TMP$ORG$PLIST
    echo "<!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'>" >> $TMP$ORG$PLIST
    echo "<plist version='1.0'>" >> $TMP$ORG$PLIST
    echo "<dict>" >> $TMP$ORG$PLIST
    echo -e "\t<key>Label</key>" >> $TMP$ORG$PLIST
    echo -e "\t<string>org.learningequality.kalite</string>" >> $TMP$ORG$PLIST
    echo -e "\t<key>ProgramArguments</key>" >> $TMP$ORG$PLIST
    echo -e "\t<array>" >> $TMP$ORG$PLIST
    echo -e "\t\t<string>sh</string>" >> $TMP$ORG$PLIST
    echo -e "\t\t<string>-c</string>" >> $TMP$ORG$PLIST
    echo -e "\t\t<string>launchctl setenv KALITE_PYTHON \"$TO_KALITE_PYTHON\"</string>" >> $TMP$ORG$PLIST
    echo -e "\t</array>" >> $TMP$ORG$PLIST
    echo -e "\t<key>RunAtLoad</key>" >> $TMP$ORG$PLIST
    echo -e "\t<true/>" >> $TMP$ORG$PLIST
    echo "</dict>" >> $TMP$ORG$PLIST
    echo "</plist>" >> $TMP$ORG$PLIST

    # As root, copy the .plist into /Library/LaunchAgents/
    if [ -f "$TARGET$ORG$PLIST" ]; then
        echo "PLIST is already exist in $TARGET"
    else
        sudo cp $TMP$ORG$PLIST $TARGET$ORG$PLIST
    fi
fi

echo "Running  manage setup.."
kalite manage syncdb --noinput
kalite manage setup --noinput
if [ $? -ne 0 ]; then
    syslog -s -l error "Error/s encountered running kalite manage syncdb --noinput"
    # TODO(eduard):  We encountered a error on kalite manage setup --noinput 
    # REF: Issue References https://github.com/learningequality/ka-lite/pull/4630#issuecomment-155562193
    # exit 1
fi

echo "Unpacking assessment.zip"
kalite manage unpack_assessment_zip $ASSESSMENT_SRC
if [ $? -ne 0 ]; then
    syslog -s -l error "Error/s encountered running kalite manage syncdb --noinput"
    # exit 1
fi
