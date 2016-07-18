#!/usr/bin/env bash
# **************************************************
# Additional script that run internally in the docker image.
#
# Steps
#   1. Check if kalite.zip is available or redownload and extraxt it to the working directory.
#   2. Run `python setup.py sdist --static` inside the `temp/ka-lite/` directory.
#   3. Run mk-build-deps -i -r -t 'apt-get -y' inside the `debian/control` directory
#   4. Run `debuild -b -us -uc` in the `ka-lite-source-0.16.6/kalite` directory for packaging.
#   5. Collect the *.deb in the `temp/installers` directory

STEP=0
STEPS=6

echo "Now running the Additional script..."
# REF: http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself/4774063#comment15185627_4774063
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
TEMP_DIR_NAME="ka-lite-source-0.16.6"
WORKING_DIR="/$TEMP_DIR_NAME"
DEB_INSTALLER_DIR="installers"


KA_LITE="ka-lite"
KA_LITE_ZIP="$WORKING_DIR/$KA_LITE.zip"
KA_LITE_DIR="$WORKING_DIR/$KA_LITE"
VERSION="0.16"
KA_LITE_REPO_ZIP="https://github.com/learningequality/ka-lite/archive/$VERSION.x.zip"
PANTRY_CONTENT_URL="http://pantry.learningequality.org/downloads/ka-lite/$VERSION/content"

DEBUILD_CMD="debuild -b -us -uc"


DEBIAN_CONTROL_FOLDER_CP="cp -R $WORKING_DIR/debian $KA_LITE_DIR/debian"
COLLECT_DEB_MV="mv $WORKING_DIR/*.deb $WORKING_DIR/$DEB_INSTALLER_DIR"


CONTENT_DIR="$WORKING_DIR/content"
CONTENTPACKS_DIR="$CONTENT_DIR/contentpacks"

# Check if an argument was passed as URL for the en.zip and use that instead.
CONTENTPACKS_EN_ZIP="en.zip"
CONTENTPACKS_EN_URL="$PANTRY_CONTENT_URL/contentpacks/$CONTENTPACKS_EN_ZIP"
if [ "$2" != "" ]; then
    echo ".. Checking validity of en.zip argument -- $2..."
    # MUST: Check if valid url!
    if curl --output /dev/null --silent --head --fail "$2"
    then
        # Use the argument as the en.zip url.
        CONTENTPACKS_EN_URL=$2
    else
        echo ".. Abort!  The '$2' argument is not a valid URL for the en.zip!"
        exit 1
    fi
fi

if ! [ -d "$WORKING_DIR" ]; then
    echo ".. Creating temporary directory named '$WORKING_DIR'..."
    mkdir "$WORKING_DIR"
fi

((STEP++))
echo "$STEP/$STEPS. Checking if '$KA_LITE_REPO_ZIP' is available or re-download..."

# Don't download the KA-Lite repo if there's already a `ka-lite` directory.
if [ -d "$KA_LITE_DIR" ]; then
    echo ".. Found ka-lite directory '$KA_LITE_DIR' so will not download and extract zip."
else
    # Get KA-Lite repo
    if [ -e "$KA_LITE_ZIP" ]; then
        echo ".. Found '$KA_LITE_ZIP' file so will not re-download.  Delete this file to re-download."
    else
        # REF: http://stackoverflow.com/a/18222354/84548ƒ®1
        # How to download source in .zip format from GitHub?
        echo ".. Downloading from '$KA_LITE_REPO_ZIP' to '$KA_LITE_ZIP'..."
        wget --retry-connrefused --read-timeout=20 --waitretry=1 -t 100 --continue -O $KA_LITE_ZIP $KA_LITE_REPO_ZIP
        if [ $? -ne 0 ]; then
            echo ".. Abort!  Can't download 'ka-lite' source."
            exit 1
        fi
    fi

    # Extract KA-Lite
    echo ".. Extracting '$KA_LITE_ZIP'..."
    unzip -o $KA_LITE_ZIP -d $WORKING_DIR
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Can't extract '$KA_LITE_ZIP'."
        exit 1
    fi

#    # Rename the extracted folder.
    echo ".. Renaming '$WORKING_DIR/$KA_LITE-*' to $KA_LITE_DIR'..."
    mv $WORKING_DIR/$KA_LITE-* $KA_LITE_DIR
    if ! [ -d "$KA_LITE_DIR" ]; then
        echo ".. Abort!  Did not successfully rename '$WORKING_DIR/$KA_LITE-*' to '$KA_LITE_DIR'."
        exit 1
    fi
fi


echo "$STEP/$STEPS. Checking if requirements are installed..."
$DEBIAN_CONTROL_FOLDER_CP
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered '$DEBIAN_CONTROL_FOLDER_CP'..."
    exit 1
fi

((STEP++))
echo "$STEP/$STEPS. Upgrading Pyrun's Pip..."

# MUST: Upgrade Pyrun's pip from v1.5.6 to prevent issues.
UPGRADE_PIP_CMD="pip install --upgrade pip"
$UPGRADE_PIP_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$UPGRADE_PIP_CMD'."
    exit 1
fi


((STEP++))
echo "$STEP/$STEPS. Installing Pip requirements for use of Makefile..."

PIP_CMD="pip install -r requirements_dev.txt"
# TODO(cpauya): Streamline this to pip install only the needed modules/executables for `make dist` below.
cd "$KA_LITE_DIR"
echo ".. Running $PIP_CMD..."
$PIP_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$PIP_CMD'."
    exit 1
fi

PIP_CMD="pip install -r requirements_sphinx.txt"
# TODO(cpauya): Streamline this to pip install only the needed modules/executables for `make dist` below.
cd "$KA_LITE_DIR"
echo ".. Running $PIP_CMD..."
$PIP_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$PIP_CMD'."
    exit 1
fi


((STEP++))
echo "$STEP/$STEPS. Running 'make dist'..."

cd "$KA_LITE_DIR"
MAKE_CMD="make dist"
echo ".. Running $MAKE_CMD..."
$MAKE_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$MAKE_CMD'."
    exit 1
fi

((STEP++))
echo "$STEP/$STEPS. Running 'setup.py install --static'..."

cd "$KA_LITE_DIR"
SETUP_CMD="python setup.py"
SETUP_STATIC_CMD="$SETUP_CMD --static"
echo ".. Running $SETUP_STATIC_CMD..."
$SETUP_STATIC_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$SETUP_STATIC_CMD'."
    exit 1
fi

((STEP++))
echo "$STEP/$STEPS. Running mk-build-deps..."

cd "$KA_LITE_DIR"
mk-build-deps -i -r -t 'apt-get -y' debian/control
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running 'mk-build-deps'."
    exit 1
fi

((STEP++))
echo "$STEP/$STEPS. Now Running  '$DEBUILD_CMD'..."

cd "$KA_LITE_DIR"
$DEBUILD_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$DEBUILD_CMD'."
    exit 1
fi

((STEP++))
echo "$STEP/$STEPS. Now copying the *.deb files in  '$COLLECT_DEB_CMD'..."


cd "$WORKING_DIR"
if ! [ -d "$WORKING_DIR/$DEB_INSTALLER_DIR" ]; then
    echo ".. Creating temporary directory named '$WORKING_DIR/$DEB_INSTALLER_DIR'..."
    mkdir "$DEB_INSTALLER_DIR"
fi

$COLLECT_DEB_MV
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$WORKING_DIR/$DEB_INSTALLER_DIR'."
    exit 1
fi

