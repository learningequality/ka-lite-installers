#!/usr/bin/env bash

# Post installation script of KA-Lite to be used in Packages.

# Notes: 
# 1. This script must be run as root.
# 2. We use `/Applications/KA-Lite/support/` as the installation location which contains the `content/contentpacks/en.zip`, `Python`, and `scripts`.

# Steps
# 1. Set KALITE_PYTHON environment variable to the Python executable.
# 2. Set KALITE_PEX environment variable to the kalite PEX file executable.
# 3. Set KALITE_DIR environment variable.
# 4. Create plist in /Library/LaunchAgents/ folder.
# 5. Symlink kalite executable to /usr/local/bin.
# 6. Set KALITE_HOME environment variable to ~/.kalite/ folder.
# 7. Run kalite manage syncdb --noinput.
# 7. Run kalite manage setup --noinput.
# 8. Run kalite manage collectstatic --noinput.
# 10. Change the owner of the ~/.kalite/ folder and .plist file to current user.
# 11. Set the KALITE_PYTHON env var for the user doing the install so we don't need to restart after installation.
# 12. Set KALITE_DIR under the user account.
# 13. Set KALITE_PEX under the user account.
# 14. Create a copy of ka-lite-remover.sh and name it as KA-Lite_Uninstall.tool.


#----------------------------------------------------------------------
# Global Variables
#----------------------------------------------------------------------
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

STEP=0
STEPS=14

KALITE_SHARED="/Applications/KA-Lite/support"
KALITE_HOME_PATH="$HOME/.kalite"
KALITE_UNINSTALL_SCRIPT="KA-Lite_Uninstall.tool"
KALITE_PEX_PATH="$KALITE_SHARED/ka-lite/kalite.pex"

PYTHON="$(which python2)"
if ! $PYTHON --version >/dev/null 2>&1; then
    PYTHON="$(which python)"
fi


SCRIPT_PATH="$KALITE_SHARED/scripts/"
APPLICATION_PATH="/Applications/KA-Lite"
PRE_INSTALL_SCRIPT="$SCRIPT_PATH/ka-lite-remover.sh"

# Symlink the kalite PEX file to /usr/local/bin so that `kalite` command will be available in the terminal.
SYMLINK_FILE="$KALITE_PEX_PATH"
SYMLINK_TO="/usr/local/bin/kalite"
COMMAND_SYMLINK="ln -s $SYMLINK_FILE $SYMLINK_TO"
CONTENT_PATH="$KALITE_SHARED/content/ka-lite/"

ORG="org.learningequality.kalite"
LAUNCH_AGENTS="/Library/LaunchAgents/"
KALITE=$(which kalite)
PLIST_SRC="$LAUNCH_AGENTS$ORG.plist"


#----------------------------------------------------------------------
# Functions
#----------------------------------------------------------------------
function update_env {
    # MUST: Make sure we have a KALITE_PYTHON env var that points to PYTHON
    msg "Setting KALITE_PYTHON environment variable to $PYTHON..."
    launchctl unsetenv KALITE_PYTHON
    launchctl setenv KALITE_PYTHON "$PYTHON"
    export KALITE_PYTHON="$PYTHON"
    if [ $? -ne 0 ]; then
        msg ".. Abort!  Error/s encountered exporting KALITE_PYTHON '$PYTHON'."
        exit 1
    fi
}

function set_kalite_pex_path {
    # This will set KALITE_PEX environment variable to KA Lite PEX file executable.
    # KALITE_PEX is use in KA Lite OS X application to find KA Lite PEX executable.
    launchctl setenv KALITE_PEX "$KALITE_PEX_PATH"
    export KALITE_PEX="$KALITE_PEX_PATH"
    if [ $? -ne 0 ]; then
        msg ".. Abort!  Error/s encountered exporting KALITE_PYTHON '$PYTHON'."
        exit 1
    fi
}

function set_kalite_dir_path {
    # This will set KALITE_DIR environment variable.
    launchctl setenv KALITE_DIR "$CONTENT_PATH"
    export KALITE_DIR="$CONTENT_PATH"
    if [ $? -ne 0 ]; then
        msg ".. Abort!  Error/s encountered exporting KALITE_DIR '$CONTENT_PATH'."
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
    echo -e "\t\t<string>launchctl setenv KALITE_PYTHON \"$PYTHON\"</string>" >> $PLIST_SRC
    echo -e "\t\t<string>launchctl setenv KALITE_PEX \"$KALITE_PEX_PATH\"</string>" >> $PLIST_SRC
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


((STEP++))
msg "$STEP/$STEPS. Set KALITE_PYTHON environment variable to the python executable..."
update_env

((STEP++))
msg "$STEP/$STEPS. Set KALITE_PEX environment ..."
set_kalite_pex_path

((STEP++))
msg "$STEP/$STEPS. Set KALITE_DIR environment ..."
set_kalite_dir_path

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
msg "$STEP/$STEPS. Symlink kalite executable to $SYMLINK_TO..."
$COMMAND_SYMLINK
if [ $? -ne 0 ]; then
    msg ".. Abort!  Error encountered running '$COMMAND_SYMLINK'."
    exit 1
fi

((STEP++))
# TODO(arceduardvincent): Remove this step when the issue is solved.
# Remove the old asset folder to be replaced by newer assets later.
# REF: https://github.com/learningequality/installers/issues/337#issuecomment-171127297

# Use the KALITE_HOME env var if it exists or use the default value.
KALITE_HOME_DEFAULT="$HOME/.kalite/"
if [ -z ${KALITE_HOME+0} ]; then
    KALITE_HOME=$KALITE_HOME_DEFAULT
else
    # If path of $KALITE_HOME does not exist, use the default location
    if [ ! -d "$KALITE_HOME" ]; then
        KALITE_HOME=$KALITE_HOME_DEFAULT
    fi
fi

KALITE_ASSET_FOLDER="$KALITE_HOME/httpsrv/"
msg "$STEP/$STEPS. Removing the old asset folder at '$KALITE_ASSET_FOLDER' to be replaced later..."
if [ -d "$KALITE_ASSET_FOLDER" ]; then
    rm -Rf "$KALITE_ASSET_FOLDER"
    if [ $? -ne 0 ]; then
        msg ".. Abort!  Error removing the $KALITE_ASSET_FOLDER."
        exit 1
    fi
fi

((STEP++))
msg "$STEP/$STEPS. Running kalite manage syncdb --noinput..."
$KALITE_PEX_PATH manage syncdb --noinput

((STEP++))
msg "$STEP/$STEPS. Set KALITE_PEX environment ..."
$KALITE_PEX_PATH manage setup --noinput

((STEP++))
msg "$STEP/$STEPS. Running kalite manage collectstatic --noinput..."
$KALITE_PEX_PATH  manage collectstatic --noinput

((STEP++))
# Change the owner of the ~/.kalite/ folder.
msg "$STEP/$STEPS. Changing the owner of the '$KALITE_DIR' and '$PLIST_SRC' to the current user $USER..."
chown -R $USER:$SUDO_GID $KALITE_HOME_PATH
chown -R $USER:$SUDO_GID $CONTENT_PATH
chown -R $USER:$SUDO_GID $PLIST_SRC

((STEP++))
# Set the KALITE_PYTHON env var for the user doing the install so we don't need to restart after installation.
msg "$STEP/$STEPS. Set the KALITE_PYTHON env var for the user doing the install so we don't need to restart after installation..."
# MUST: Do an unsetenv first because the env var may already be set.  This is useful during upgrade.
su $USER -c "launchctl unsetenv KALITE_PYTHON"
su $USER -c "launchctl setenv KALITE_PYTHON $PYTHON"
if [ $? -ne 0 ]; then
    msg ".. Abort!  Error setting the KALITE_PYTHON env var under the user account."
    exit 1
fi
msg "KALITE_PYTHON env var is now set to $KALITE_PYTHON"

((STEP++))
# Set the KALITE_DIR env var for the user doing the install so we don't need to restart after installation.
msg "$STEP/$STEPS. Set the KALITE_DIR env var for the user doing the install so we don't need to restart after installation..."
# MUST: Do an unsetenv first because the env var may already be set.  This is useful during upgrade.
su $USER -c "launchctl unsetenv KALITE_DIR"
su $USER -c "launchctl setenv KALITE_DIR $KALITE_DIR"
if [ $? -ne 0 ]; then
    msg ".. Abort!  Error setting the KALITE_DIR env var under the user account."
    exit 1
fi
msg "KALITE_DIR env var is now set to $KALITE_DIR"

((STEP++))
msg "$STEP/$STEPS. Set the KALITE_PEX env var for the user doing the install so we don't need to restart after installation..."
su $USER -c "launchctl unsetenv KALITE_PEX"
su $USER -c "launchctl setenv KALITE_PEX $KALITE_PEX_PATH"
if [ $? -ne 0 ]; then
    msg ".. Abort!  Error setting the KALITE_PEX env var under the user account."
    exit 1
fi
msg "KALITE_PEX env var is now set to $KALITE_PYTHON"

((STEP++))
# Create a copy of ka-lite-remover.sh and name it as KA-Lite_Uninstall.tool.
msg "$STEP/$STEPS. Creating a $KALITE_UNINSTALL_SCRIPT..."
cp -R "$PRE_INSTALL_SCRIPT" "$APPLICATION_PATH/$KALITE_UNINSTALL_SCRIPT"
if [ $? -ne 0 ]; then
    msg ".. Abort!  Error creating a $KALITE_UNINSTALL_SCRIPT."
    exit 1
fi

msg "Done with post installation!"

KALITE_APP="$APPLICATION_PATH/KA-Lite.app"
if [ -d "$KALITE_APP" ]; then
    msg "Will open '$KALITE_APP' now."
    open "$KALITE_APP"
    msg "$KALITE_APP opened successfully."
else
    msg "Cannot auto-open $KALITE_APP."
fi
