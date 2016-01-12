#!/usr/bin/env bash

# Post installation script of KA-Lite to be used in Packages.

# Notes: 
# 1. This script must be run as root.
# 2. We use `/Users/Shared/ka-lite/` as the installation location which contains the `assessment.zip`, `pyrun`, and `scripts`.

# Steps
# 1. Symlink kalite executable to /usr/local/bin.
# 2. Export KALITE_PYTHON env that point to Pyrun directory.
# 3. Create plist in /Library/LaunchAgents/ folders.
# 4. Run shebangcheck that check the BIN_PATH that points to the python/pyrun interpreter to use.
# 5. Run kalite manage syncdb --noinput.
# 6. Run kalite manage init_content_items --overwrite.
# 7. Run kalite manage unpack_assessment_zip <assessment_path>.
# 8. Run kalite manage setup --noinput..
# 9. Change the owner of the ~/.kalite/ folder.
# 10. Create a copy of ka-lite-remover.sh and name it as KA-Lite_Uninstall.tool.

#----------------------------------------------------------------------
# Global Variables
#----------------------------------------------------------------------
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

KALITE_SHARED="/Users/Shared/ka-lite"
KALITE_DIR="$HOME/.kalite"
KALITE_UNINSTALL_SCRIPT="KA-Lite_Uninstall.tool"
PYRUN_NAME="pyrun-2.7"
PYRUN_DIR="$KALITE_SHARED/$PYRUN_NAME"
PYRUN="$PYRUN_DIR/bin/pyrun"
PYRUN_PIP="$PYRUN_DIR/bin/pip"
BIN_PATH="$PYRUN_DIR/bin"
ASSESSMENT_SRC="$KALITE_SHARED/assessment/assessment.zip"
SCRIPT_PATH="$KALITE_SHARED/scripts/"
APPLICATION_PATH="/Applications/KA-Lite"
PRE_INSTALL_SCRIPT="$SCRIPT_PATH/ka-lite-remover.sh"

SYMLINK_FILE="$KALITE_SHARED/pyrun-2.7/bin/kalite"
SYMLINK_TO="/usr/local/bin"
COMMAND_SYMLINK="ln -sf $SYMLINK_FILE $SYMLINK_TO"

ORG="org.learningequality.kalite"
LAUNCH_AGENTS="/Library/LaunchAgents/"
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

    if [ -f "$PLIST_SRC" ]; then
        echo ".. Now removing '$PLIST_SRC'..."
        rm -fr $PLIST_SRC
        if [ $? -ne 0 ]; then
            echo ".. Abort!  Error/s encountered removing '$PLIST_SRC'."
            exit 1
        fi
    fi

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

    if [ -f "$PLIST_SRC" ]; then
        echo ".. $PLIST_SRC created successfully"
    else
        if [ $? -ne 0 ]; then
            echo ".. Abort!  Error/s encountered creating '$PLIST_SRC'."
            exit 1
        fi
    fi
}

#----------------------------------------------------------------------
# Script
#----------------------------------------------------------------------

ENV=$(env)
syslog -s -l alert "Packages post-installation initialize with env:'\n'$ENV" 

STEP=1
STEPS=11

echo "Now preparing KA-Lite dependencies..."

echo "$STEP/$STEPS. Symlink kalite executable to /usr/bin/..."
if [ ! -d "$SYMLINK_TO" ]; then
    echo ".. Now creating '$SYMLINK_TO'..."
    sudo mkdir -p $SYMLINK_TO
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Error encountered creating '$SYMLINK_TO' directory."
        exit 1
    fi
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
if [ ! -d "$LAUNCH_AGENTS" ]; then
    echo ".. Must create '$LAUNCH_AGENTS' folder..."
    sudo mkdir -p $LAUNCH_AGENTS
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Error encountered creating '$LAUNCH_AGENTS' directory."
        exit 1
    fi
fi


((STEP++))
echo "$STEP/$STEPS. Create plist in /Library/LaunchAgents folders..."
if [ ! -d "$LAUNCH_AGENTS" ]; then
    echo ".. Must create '$LAUNCH_AGENTS' folder..."
    sudo mkdir -p $LAUNCH_AGENTS
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Error encountered creating '$LAUNCH_AGENTS' directory."
        exit 1
    fi
fi
create_plist


((STEP++))
echo "$STEP/$STEPS. Check the BIN_PATH that points to the python/pyrun interpreter to use..."
$PYRUN $SCRIPT_PATH/shebangcheck.py
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error encountered running '$SCRIPT_PATH/shebangcheck.py'."
    exit 1
fi


((STEP++))
echo "$STEP/$STEPS. Running kalite manage syncdb --noinput..."
$BIN_PATH/kalite manage syncdb --noinput


# REF: https://github.com/learningequality/ka-lite/issues/4682#issuecomment-159113225
# TODO(djallado): Remove command `kalite manage init_content_items --overwrite` after the issue in pressing `Learn` tab 
# that results an empty sidebar and `Unexpected error: argument 2 to map() must support iteration` error will be solved.
((STEP++))
echo "$STEP/$STEPS. Running kalite manage init_content_items --overwrite..."
$BIN_PATH/kalite manage init_content_items --overwrite


((STEP++))
echo "$STEP/$STEPS. Running kalite manage unpack_assessment_zip '$ASSESSMENT_SRC'..."
$BIN_PATH/kalite manage unpack_assessment_zip $ASSESSMENT_SRC    


((STEP++))
echo "$STEP/$STEPS. Running kalite manage setup --noinput..."
$BIN_PATH/kalite manage setup --noinput


((STEP++))
echo "$STEP/$STEPS. Changing the owner of the '$KALITE_DIR' and '$PLIST_SRC' to the current user $USER..."
# PLIST_SRC="/Library/LaunchAgents/org.learningequality.kalite.plist"
chown -R $USER:$SUDO_GID $KALITE_DIR
chown -R $USER:$SUDO_GID $PLIST_SRC

((STEP++))
echo "$STEP/$STEPS. Manually load the '$PLIST_SRC.'"
# su $USER -c '"'launchctl load -w $PLIST_SRC'"'
# TODO(arceduardvincent): Used $PLIST_SRC
su $USER -c "launchctl load -w /Library/LaunchAgents/org.learningequality.kalite.plist"
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error loading of '$PLIST_SRC'."
    exit 1
fi

((STEP++))
echo "$STEP/$STEPS. Creating a $KALITE_UNINSTALL_SCRIPT..."
cp -R "$PRE_INSTALL_SCRIPT" "$APPLICATION_PATH/$KALITE_UNINSTALL_SCRIPT"
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error creating a $KALITE_UNINSTALL_SCRIPT."
    exit 1
fi

echo "Done!"
