#!/usr/bin/env bash
# **************************************************
# Additional script that run internally in the docker image.
#

APP_DIR="/installers"

STEP=0
STEPS=1

echo "Now running the Additional script..."

((STEP++))
echo "$STEP/$STEPS. Checking Github source..."
# REF: http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself/4774063#comment15185627_4774063
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
TEMP_DIR_NAME="ka-lite-source-0.16.6"
WORKING_DIR="/$TEMP_DIR_NAME/temp"

KA_LITE="ka-lite"
KA_LITE_ZIP="$WORKING_DIR/$KA_LITE.zip"
KA_LITE_DIR="$WORKING_DIR/$KA_LITE"
VERSION="0.16"
KA_LITE_REPO_ZIP="https://github.com/learningequality/ka-lite/archive/$VERSION.x.zip"


# rm -fr $WORKING_DIR/$KA_LITE
if ! [ -d "$WORKING_DIR" ]; then
    echo ".. Creating temporary directory named '$WORKING_DIR'..."
    mkdir "$WORKING_DIR"
fi

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

((STEP++))
echo "$STEP/$STEPS. Running 'setup.py install --static'..."

cd "$KA_LITE_DIR"
SETUP_CMD="python setup.py"
SETUP_STATIC_CMD="$SETUP_CMD sdist --static"
echo ".. Running $SETUP_STATIC_CMD..."
$SETUP_STATIC_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$SETUP_STATIC_CMD'."
    exit 1
fi

cd "$KA_LITE_DIR"
MK_BUILD_DEPS="mk-build-deps --remove --install"
$MK_BUILD_DEPS debian/control
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$MK_BUILD_DEPS'."
    exit 1
fi

cd "$KA_LITE_DIR"
DEBUILD="debuild -b -us -uc"
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$DEBUILD'."
    exit 1
fi


