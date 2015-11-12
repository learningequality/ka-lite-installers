#!/bin/bash
# set -ex
# Above is very useful during debugging.
# 
# **************************************************
# Build script for KA-Lite using Packages and PyRun.
#
# STEPS
# . Create temporary directory `temp`.
# . Check if requirements are installed: packages, wget.
# . Get Github source, based on argument of branch URL, extract and rename it to `ka-lite` folder.
# . Get Pyrun
# . Do `pyrun setup.py sdist --static` inside the `temp/ka-lite/` directory.
#
# REF: Bash References
# * http://www.peterbe.com/plog/set-ex
# * http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
# * http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself/4774063#4774063
# * http://askubuntu.com/questions/385528/how-to-increment-a-variable-in-bash#385532
# * http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
# * http://stackoverflow.com/questions/2924422/how-do-i-determine-if-a-web-page-exists-with-shell-scripting/20988182#20988182
# * http://stackoverflow.com/questions/2751227/how-to-download-source-in-zip-format-from-github/18222354#18222354

echo "KA-Lite OS X build script for version 0.16.x and above."

STEP=1
STEPS=5

# REF: http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself/4774063#comment15185627_4774063
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

# Create temporary directory
TEMP_DIR_NAME="temp"
WORKING_DIR="$SCRIPTPATH/$TEMP_DIR_NAME"

echo "$STEP/$STEPS. Checking temporary directory..."
if ! [ -d "$WORKING_DIR" ]; then
    echo ".. Creating temporary directory named '$WORKING_DIR'..."
    mkdir "$WORKING_DIR"
fi


((STEP++))
echo "$STEP/$STEPS. Checking if requirements are installed..."

PACKAGES_EXEC="packagesbuild"
if ! command -v $PACKAGES_EXEC >/dev/null 2>&1; then
    echo ".. Abort! Packages is not installed."
    exit 1
fi

PACKAGES_EXEC="wget"
if ! command -v $PACKAGES_EXEC >/dev/null 2>&1; then
    echo ".. Abort! wget is not installed."
    exit 1
fi


((STEP++))
echo "$STEP/$STEPS. Checking Github source..."

KA_LITE="ka-lite"
KA_LITE_ZIP="$WORKING_DIR/$KA_LITE.zip"
KA_LITE_DIR="$WORKING_DIR/$KA_LITE"

# Don't download the KA-Lite repo if there's already a `ka-lite` directory.
if [ -d "$KA_LITE_DIR" ]; then
    echo ".. Found ka-lite directory '$KA_LITE_DIR' so will not download and extract zip."
else
    # MUST: Use the archive link, which defaults to develop branch, so that the folder name
    # starts with the repo name like these examples:
    #    ka-lite-develop
    #    ka-lite-0.14.x.zip
    # this will make it easier to "rename" the archive.
    KA_LITE_REPO_ZIP="https://github.com/learningequality/ka-lite/archive/develop.zip"

    # Check if an argument was passed as URL for the script and use that instead.
    if [ "$1" != "" ]; then
        # MUST: Check if valid url!
        if curl --output /dev/null --silent --head --fail "$1"
        then
            # Use the argument as the ka-lite repo zip.
            KA_LITE_REPO_ZIP=$1
        else
            echo "The $1 argument is not a valid URL for the Github repo!"
            exit 1
        fi
    fi

    # Get KA-Lite repo
    if [ -e "$KA_LITE_ZIP" ]; then
        echo ".. Found '$KA_LITE_ZIP' file so will not re-download.  Delete this file to re-download."
    else
        # REF: http://stackoverflow.com/a/18222354/84548ƒ®1
        # How to download source in .zip format from GitHub?
        # TODO(cpauya): Download from `master` branch NOT from `develop`.
        echo ".. Downloading from '$KA_LITE_REPO_ZIP' to '$KA_LITE_ZIP'..."
        wget --retry-connrefused --read-timeout=20 --waitretry=1 -t 100 --continue -O $KA_LITE_ZIP $KA_LITE_REPO_ZIP
        if [ $? -ne 0 ]; then
            echo ".. Abort!  Can't download 'ka-lite' source."
            exit 1
        fi
    fi

    # Extract KA-Lite
    echo ".. Extracting '$KA_LITE_ZIP'..."
    tar -xf $KA_LITE_ZIP -C $WORKING_DIR
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Can't extract '$KA_LITE_ZIP'."
        exit 1
    fi

    # Rename the extracted folder.
    echo ".. Renaming '$WORKING_DIR/$KA_LITE-*' to $KA_LITE_DIR'..."
    mv $WORKING_DIR/$KA_LITE-* $KA_LITE_DIR
    if ! [ -d "$KA_LITE_DIR" ]; then
        echo ".. Abort!  Did not successfully rename '$WORKING_DIR/$KA_LITE-*' to '$KA_LITE_DIR'."
        exit 1
    fi
fi


((STEP++))
echo "$STEP/$STEPS. Checking Pyrun..."

INSTALL_PYRUN_URL="https://downloads.egenix.com/python/install-pyrun"
INSTALL_PYRUN="$WORKING_DIR/install-pyrun.sh"
PYRUN_NAME="pyrun-2.7"
PYRUN_DIR="$WORKING_DIR/$PYRUN_NAME"
PYRUN="$PYRUN_DIR/bin/pyrun"
PYRUN_PIP="$PYRUN_DIR/bin/pip"

# Don't download Pyrun if there's already a `pyrun-2.7` directory.
if [ -d "$PYRUN_DIR" ]; then
    echo ".. Found PyRun directory at '$PYRUN_DIR' so will not re-download.  Delete this folder to re-download."
else
    # Download install-pyrun
    if [ -e "$INSTALL_PYRUN" ]; then
        echo ".. Found '$INSTALL_PYRUN' so will not re-download.  Delete this file to re-download."
    else
        echo ".. Downloading 'install-pyrun' script..."
        wget --retry-connrefused --read-timeout=20 --waitretry=1 -t 100 --continue -O $INSTALL_PYRUN $INSTALL_PYRUN_URL
        if [ $? -ne 0 ]; then
          echo ".. Abort!  Can't download 'install-pyrun' script."
          exit 1
        fi
        chmod +x $INSTALL_PYRUN
    fi

    # Download PyRun.
    echo ".. Downloading PyRun with Python 2.7..."
    $INSTALL_PYRUN --python=2.7 $PYRUN_DIR
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Can't install minimal PyRun."
        exit 1
    fi
fi


((STEP++))
echo "$STEP/$STEPS. Running 'sdist'..."

# MUST: Upgrade Pyrun's pip from v1.5.6 to prevent issues.
UPGRADE_PIP_CMD="$PYRUN_PIP install --upgrade pip"
echo ".. Upgrading Pyrun's pip with '$UPGRADE_PIP_CMD'..."
$UPGRADE_PIP_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$UPGRADE_PIP_CMD'."
    exit 1
fi

# TODO(cpauya): Still here for reference until done debugging.
# cd "$KA_LITE_DIR"
# SDIST_CMD="$PYRUN -m pip install ."
# echo ".. Running $SDIST_CMD..."
# $SDIST_CMD
# if [ $? -ne 0 ]; then
#     echo ".. Abort!  Error/s encountered running '$SDIST_CMD'."
#     exit 1
# fi

cd "$KA_LITE_DIR"
SETUP_CMD="$PYRUN setup.py install"
echo ".. Running $SETUP_CMD..."
$SETUP_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$SETUP_CMD'."
    exit 1
fi

cd "$KA_LITE_DIR"
SETUP_STATIC_CMD="$SETUP_CMD --static"
echo ".. Running $SETUP_STATIC_CMD..."
$SETUP_STATIC_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$SETUP_STATIC_CMD'."
    exit 1
fi

cd "$WORKING_DIR/.."
echo "Done!"