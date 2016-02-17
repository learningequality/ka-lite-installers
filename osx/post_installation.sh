#!/usr/bin/env bash

# Post installation script of KA-Lite to be used in Packages.

# Notes: 
# 1. This script must be run as root.
# 2. We use `/Users/Shared/ka-lite/` as the installation location which contains the `assessment.zip`, `pyrun`, and `scripts`.

# Steps
# 1. Symlink kalite executable to /usr/local/bin.
# 2. Set KALITE_PYTHON environment variable to the Pyrun executable.
# 3. Create plist in /Library/LaunchAgents/ folder.
# 4. Run shebangcheck script that checks the python/pyrun interpreter to use.
# 5. Remove the old asset folder to be replaced by newer assets later.
# 6. Run kalite manage syncdb --noinput.

# 7. Run kalite manage init_content_items --overwrite.
# TODO(cpauya): use Pantry's content.db or retrievecontentpack
# * replace /ka-lite/content_databases/content_khan_en.sqlite with Pantry's content.db
# * use retrievecontentpack

# 8. Run kalite manage unpack_assessment_zip <assessment_path>.
# 9. Run kalite manage setup --noinput..
# 10. Change the owner of the ~/.kalite/ folder and .plist file to current user.
# 11. Set the KALITE_PYTHON env var for the user doing the install so we don't need to restart after installation.
# 12. Create a copy of ka-lite-remover.sh and name it as KA-Lite_Uninstall.tool.


#----------------------------------------------------------------------
# Global Variables
#----------------------------------------------------------------------
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

STEP=1
STEPS=12

KALITE_SHARED="/Users/Shared/ka-lite"
KALITE_DIR="$HOME/.kalite"
KALITE_UNINSTALL_SCRIPT="KA-Lite_Uninstall.tool"
PYRUN_NAME="pyrun-2.7"
PYRUN_DIR="$KALITE_SHARED/$PYRUN_NAME"
PYRUN="$PYRUN_DIR/bin/pyrun"
PYRUN_PIP="$PYRUN_DIR/bin/pip"
BIN_PATH="$PYRUN_DIR/bin"
ASSESSMENT_SRC="$KALITE_SHARED/content/assessment.zip"
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
    msg "Setting KALITE_PYTHON environment variable to $PYRUN..."
    launchctl unsetenv KALITE_PYTHON
    launchctl setenv KALITE_PYTHON "$PYRUN"
    export KALITE_PYTHON="$PYRUN"
    if [ $? -ne 0 ]; then
        msg ".. Abort!  Error/s encountered exporting KALITE_PYTHON '$PYRUN'."
        exit 1
    fi
}


function create_plist {

    if [ -f "$PLIST_SRC" ]; then
        msg ".. Now removing '$PLIST_SRC'..."
        rm -fr $PLIST_SRC
        if [ $? -ne 0 ]; then
            msg ".. Abort!  Error/s encountered removing '$PLIST_SRC'."
            exit 1
        fi
    fi

    # Create Plist 
    msg "Now creating '$PLIST_SRC'..."
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
        msg ".. $PLIST_SRC created successfully"
    else
        if [ $? -ne 0 ]; then
            msg ".. Abort!  Error/s encountered creating '$PLIST_SRC'."
            exit 1
        fi
    fi
}

# Print message in terminal and log for the Console application.
function msg() {
    echo "$1"
    syslog -s -l alert "KA-Lite: $1"
}


#----------------------------------------------------------------------
# Script
#----------------------------------------------------------------------

msg "Post-installation: Preparing KA-Lite dependencies..."

ENV=$(env)
msg ".. Packages post-installation env:'\n'$ENV" 


msg "$STEP/$STEPS. Symlink kalite executable to $SYMLINK_TO..."
if [ ! -d "$SYMLINK_TO" ]; then
    msg ".. Now creating '$SYMLINK_TO'..."
    sudo mkdir -p $SYMLINK_TO
    if [ $? -ne 0 ]; then
        msg ".. Abort!  Error encountered creating '$SYMLINK_TO' directory."
        exit 1
    fi
fi

$COMMAND_SYMLINK
if [ $? -ne 0 ]; then
    msg ".. Abort!  Error encountered running '$COMMAND_SYMLINK'."
    exit 1
fi


((STEP++))
msg "$STEP/$STEPS. Set KALITE_PYTHON environment variable to the Pyrun executable..."
update_env


((STEP++))
msg "$STEP/$STEPS. Creating and loading plist in $LAUNCH_AGENTS folder..."
if [ ! -d "$LAUNCH_AGENTS" ]; then
    # It's unlikely that the directory does not exist but nevertheless let's leave it here.
    msg ".. Must create '$LAUNCH_AGENTS' folder..."
    sudo mkdir -p $LAUNCH_AGENTS
    if [ $? -ne 0 ]; then
        msg ".. Abort!  Error encountered creating '$LAUNCH_AGENTS' directory."
        exit 1
    fi
fi
create_plist


((STEP++))
msg "$STEP/$STEPS. Run shebangcheck script that checks the python/pyrun interpreter to use..."
$PYRUN $SCRIPT_PATH/shebangcheck.py
if [ $? -ne 0 ]; then
    msg ".. Abort!  Error encountered running '$SCRIPT_PATH/shebangcheck.py'."
    exit 1
fi

# REF: https://github.com/learningequality/installers/issues/337#issuecomment-171127297
# TODO(arceduardvincent): Remove this step when the issue is solved.
((STEP++))

# Use the KALITE_HOME env var if it exists or use the default value.
if [ -z ${KALITE_HOME+0} ]; then 
  KALITE_HOME="$HOME/.kalite/"
fi

# Remove the old asset folder to be replaced by newer assets later.
KALITE_ASSET_FOLDER="$KALITE_HOME/httpsrv/"
if [ -d "$KALITE_ASSET_FOLDER" ]; then
    msg "$STEP/$STEPS. Removing the old asset folder at $KALITE_ASSET_FOLDER..."
    rm -Rf "$KALITE_ASSET_FOLDER"
    if [ $? -ne 0 ]; then
        msg ".. Abort!  Error removing the $KALITE_ASSET_FOLDER."
        exit 1
    fi
fi


((STEP++))
msg "$STEP/$STEPS. Running kalite manage syncdb --noinput..."
$BIN_PATH/kalite manage syncdb --noinput


# TODO(cpauya): use `kalite manage retrievecontentpack local en path-to-en.zip`.
# ((STEP++))
# msg "$STEP/$STEPS. Running $BIN_PATH/kalite manage retrievecontentpack local en $CONTENTPACK_ZIP..."
# CONTENTPACK_ZIP="$KALITE_SHARED/content/contentpacks/en.zip"
# $BIN_PATH/kalite manage retrievecontentpack local en $CONTENTPACK_ZIP


# TODO(cpauya): For now, use the `content.db` from Pantry and copy it to `~/.kalite/content_databases/content_khan_en.sqlite`.
((STEP++))
CONTENT_DB="$KALITE_SHARED/content/contentpacks/content.db"
CONTENT_DB_DEST="$KALITE_HOME/content_databases/content_khan_en.sqlite"
msg "$STEP/$STEPS. Copying CONTENT_DB to CONTENT_DB_DEST..."
cp "$CONTENT_DB" "$CONTENT_DB_DEST"


((STEP++))
msg "$STEP/$STEPS. Running kalite manage unpack_assessment_zip '$ASSESSMENT_SRC'..."
$BIN_PATH/kalite manage unpack_assessment_zip $ASSESSMENT_SRC


((STEP++))
msg "$STEP/$STEPS. Running kalite manage setup --noinput..."
$BIN_PATH/kalite manage setup --noinput


((STEP++))
# Change the owner of the ~/.kalite/ folder.
msg "$STEP/$STEPS. Changing the owner of the '$KALITE_DIR' and '$PLIST_SRC' to the current user $USER..."
chown -R $USER:$SUDO_GID $KALITE_DIR
chown -R $USER:$SUDO_GID $PLIST_SRC


((STEP++))
# Set the KALITE_PYTHON env var for the user doing the install so we don't need to restart after installation.
msg "$STEP/$STEPS. Set the KALITE_PYTHON env var for the user doing the install so we don't need to restart after installation..."
# MUST: Do an unsetenv first because the env var may already be set.  This is useful during upgrade.
su $USER -c "launchctl unsetenv KALITE_PYTHON"
su $USER -c "launchctl setenv KALITE_PYTHON $PYRUN"
if [ $? -ne 0 ]; then
    msg ".. Abort!  Error setting the KALITE_PYTHON env var under the user account."
    exit 1
fi
msg "KALITE_PYTHON env var is now set to $KALITE_PYTHON"


((STEP++))
# Create a copy of ka-lite-remover.sh and name it as KA-Lite_Uninstall.tool.
msg "$STEP/$STEPS. Creating a $KALITE_UNINSTALL_SCRIPT..."
cp -R "$PRE_INSTALL_SCRIPT" "$APPLICATION_PATH/$KALITE_UNINSTALL_SCRIPT"
if [ $? -ne 0 ]; then
    msg ".. Abort!  Error creating a $KALITE_UNINSTALL_SCRIPT."
    exit 1
fi

msg "Done with post installation!"
