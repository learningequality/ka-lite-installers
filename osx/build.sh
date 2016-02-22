#!/bin/bash
# set -ex
# The above is very useful during debugging.
# 
# **************************************************
# Build script for KA-Lite using Packages and PyRun.
#
# Arguments
# . $1 == $KA_LITE_REPO_ZIP == URL of the Github .zip of the KA-Lite branch to use. 
#
# Steps
# . Check if requirements are installed: packages, wget.
# . Check for valid arguments in terminal.
# . Create temporary directory `temp`.
# . Download the assessment.zip.
# . Download the contentpacks/content.db.
# . TODO(cpauya): Download the contentpacks/en.zip.  Replace the content.db step below when the retrievecontentpacks command is okay.
# . Get Github source, optionally use argument for the Github .zip URL, extract, and rename it to `ka-lite`.
# . Get Pyrun, then insert path to the Pyrun binaries in $PATH so Pyrun's python runs first instead of the system python.
# . Upgrade Pyrun's Pip
# . Run `pip install -r requirements_dev.txt` to install the Makefile executables.
# . Run `make dist` for assets and docs.
# . Run `pyrun setup.py install --static` inside the `temp/ka-lite/` directory.
# . Build the Xcode project.
# . Codesign the built .app if running on build server.
# . Run Packages script to build the .pkg.
#
# REF: Bash References
# . http://www.peterbe.com/plog/set-ex
# . http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
# . http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself/4774063#4774063
# . http://askubuntu.com/questions/385528/how-to-increment-a-variable-in-bash#385532
# . http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
# . http://stackoverflow.com/questions/2924422/how-do-i-determine-if-a-web-page-exists-with-shell-scripting/20988182#20988182
# . http://stackoverflow.com/questions/2751227/how-to-download-source-in-zip-format-from-github/18222354#18222354
#
# 
# MUST: test the signed .pkg on a target Mac with:
# pkgutil --check-signature KA-Lite.pkg -- or;
# pkgutil --check-signature KA-Lite.app -- or;
# spctl --assess --type install KA-Lite.pkg


echo "KA-Lite OS X build script for version 0.16.x and above."

STEP=0
STEPS=14

# TODO(cpauya): get version from `ka-lite/kalite/version.py`
VERSION="0.16"

PANTRY_CONTENT_URL="http://pantry.learningequality.org/downloads/ka-lite/$VERSION/content"


((STEP++))
echo "$STEP/$STEPS. Checking if requirements are installed..."

PACKAGES_EXEC="packagesbuild"
if ! command -v $PACKAGES_EXEC >/dev/null 2>&1; then
    echo ".. Abort! 'packagesbuild' is not installed."
    exit 1
fi

WGET_EXEC="wget"
if ! command -v $WGET_EXEC >/dev/null 2>&1; then
    echo ".. Abort! 'wget' is not installed."
    exit 1
fi

XCODEBUILD_EXEC="xcodebuild"
if ! command -v $XCODEBUILD_EXEC >/dev/null 2>&1; then
    echo ".. Abort! 'xcodebuild' is not installed."
    exit 1
fi


# REF: http://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself/4774063#comment15185627_4774063
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
TEMP_DIR_NAME="temp"
WORKING_DIR="$SCRIPTPATH/$TEMP_DIR_NAME"
CONTENT_DIR="$WORKING_DIR/content"
CONTENTPACKS_DIR="$CONTENT_DIR/contentpacks"


# Check the arguments
((STEP++))
echo "$STEP/$STEPS. Checking the arguments..."

# MUST: Use the archive link, which defaults to develop branch, so that the folder name
# starts with the repo name like these examples:
#    ka-lite-develop
#    ka-lite-0.14.x.zip
# this will make it easier to "rename" the archive.
# Example: KA_LITE_REPO_ZIP="https://github.com/learningequality/ka-lite/archive/develop.zip"
# KA_LITE_REPO_ZIP="https://github.com/learningequality/ka-lite/archive/develop.zip"
KA_LITE_REPO_ZIP="https://github.com/learningequality/ka-lite/archive/$VERSION.x.zip"


# Check if an argument was passed as URL for the script and use that instead.
if [ "$1" != "" ]; then
    echo ".. Checking validity of the Github repo zip argument -- $1..."
    if curl --output /dev/null --silent --head --fail "$1"
    then
        # Use the argument as the ka-lite repo zip.
        KA_LITE_REPO_ZIP=$1
    else
        echo ".. Abort!  The '$1' argument is not a valid URL for the Github repo!"
        exit 1
    fi
fi

# TODO(cpauya): Use a "develop" link for assessment items like the one for the Github repo below.
ASSESSMENT_URL="$PANTRY_CONTENT_URL/khan_assessment.zip"
# Check if an argument was passed as URL for the assessment.zip and use that instead.
if [ "$2" != "" ]; then
    echo ".. Checking validity of assessment.zip argument -- $2..."
    # MUST: Check if valid url!
    if curl --output /dev/null --silent --head --fail "$2"
    then
        # Use the argument as the assessment.zip url.
        ASSESSMENT_URL=$2
    else
        echo ".. Abort!  The '$2' argument is not a valid URL for the assessment.zip!"
        exit 1
    fi
fi
echo ".. OK, arguments are valid."


# Create temporary directory
((STEP++))
echo "$STEP/$STEPS. Checking '$WORKING_DIR' temporary directory..."
if ! [ -d "$WORKING_DIR" ]; then
    echo ".. Creating temporary directory named '$WORKING_DIR'..."
    mkdir "$WORKING_DIR"
fi


# Download the assessment.zip.
((STEP++))
ASSESSMENT_ZIP="assessment.zip"
# ASSESSMENT_PATH="$WORKING_DIR/$ASSESSMENT_ZIP"
ASSESSMENT_PATH="$CONTENT_DIR/$ASSESSMENT_ZIP"
test ! -d "$CONTENT_DIR" && mkdir -p "$CONTENT_DIR"

echo "$STEP/$STEPS. Checking for assessment.zip"
if [ -f "$ASSESSMENT_PATH" ]; then
    echo ".. Found '$ASSESSMENT_PATH' so will not re-download.  Delete it to re-download."
else
    echo ".. Downloading from '$ASSESSMENT_URL' to '$ASSESSMENT_PATH'..."
    wget --retry-connrefused --read-timeout=20 --waitretry=1 -t 100 --continue -O $ASSESSMENT_PATH $ASSESSMENT_URL
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Can't download '$ASSESSMENT_URL'."
        exit 1
    fi
fi


# # TODO(cpauya): Download the contentpacks/en.zip.  Replace the content.db codes below when the retrievecontentpacks command is okay.
# We keep these here for future use.
# ((STEP++))
# CONTENTPACKS_DIR="$WORKING_DIR/content/contentpacks"
# test ! -d "$CONTENTPACKS_DIR" && mkdir -p "$CONTENTPACKS_DIR"

# CONTENTPACKS_EN_ZIP="en.zip"
# CONTENTPACKS_EN_URL="$PANTRY_CONTENT_URL/contentpacks/$CONTENTPACKS_EN_ZIP"
# CONTENTPACKS_EN_PATH="$CONTENTPACKS_DIR/$CONTENTPACKS_EN_ZIP"
# echo "$STEP/$STEPS. Checking for en.zip"
# if [ -f "$CONTENTPACKS_EN_PATH" ]; then
#     echo ".. Found '$CONTENTPACKS_EN_PATH' so will not re-download.  Delete it to re-download."
# else
#     echo ".. Downloading from '$CONTENTPACKS_EN_URL' to '$CONTENTPACKS_EN_PATH'..."
#     wget --retry-connrefused --read-timeout=20 --waitretry=1 -t 100 --continue -O $CONTENTPACKS_EN_PATH $CONTENTPACKS_EN_URL
#     if [ $? -ne 0 ]; then
#         echo ".. Abort!  Can't download '$CONTENTPACKS_EN_URL'."
#         exit 1
#     fi
# fi


# Download the contentpacks/content.db.
((STEP++))
CONTENTPACKS_DIR="$WORKING_DIR/content/contentpacks"
test ! -d "$CONTENTPACKS_DIR" && mkdir -p "$CONTENTPACKS_DIR"

CONTENT_DB="content.db"
CONTENT_DB_URL="$PANTRY_CONTENT_URL/contentpacks/$CONTENT_DB"
CONTENT_DB_DEST="$CONTENTPACKS_DIR/$CONTENT_DB"
echo "$STEP/$STEPS. Checking for $CONTENT_DB_DEST"
if [ -f "$CONTENT_DB_DEST" ]; then
    echo ".. Found '$CONTENT_DB_DEST' so will not re-download.  Delete it to re-download."
else
    echo ".. Downloading from '$CONTENT_DB_URL' to '$CONTENT_DB_DEST'..."
    wget --retry-connrefused --read-timeout=20 --waitretry=1 -t 100 --continue -O $CONTENT_DB_DEST $CONTENT_DB_URL
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Can't download '$CONTENT_DB_URL'."
        exit 1
    fi
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
PYRUN_BIN="$PYRUN_DIR/bin"
PYRUN="$PYRUN_BIN/pyrun"
PYRUN_PIP="$PYRUN_BIN/pip"

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

# MUST: Override the PATH to add the path to the Pyrun binaries first so it's python executes instead of
# the system python.  When the script exits the old PATH values will be restored.
export PATH="$PYRUN_BIN:$PATH"


((STEP++))
echo "$STEP/$STEPS. Upgrading Pyrun's Pip..."

# MUST: Upgrade Pyrun's pip from v1.5.6 to prevent issues.
UPGRADE_PIP_CMD="$PYRUN_PIP install --upgrade pip"
$UPGRADE_PIP_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$UPGRADE_PIP_CMD'."
    exit 1
fi


((STEP++))
echo "$STEP/$STEPS. Installing Pip requirements for use of Makefile..."

PIP_CMD="$PYRUN_PIP install -r requirements_dev.txt"
# TODO(cpauya): Streamline this to install only the needed modules/executables for `make dist` below.
cd "$KA_LITE_DIR"
echo ".. Running $PIP_CMD..."
$PIP_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$PIP_CMD'."
    exit 1
fi


((STEP++))
echo "$STEP/$STEPS. Running 'make dist'..."

# MUST: Make sure we have a KALITE_PYTHON env var that points to Pyrun
# because `bin/kalite manage ...` will be called when we do `make assets`.
export KALITE_PYTHON="$PYRUN"

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
SETUP_CMD="$PYRUN setup.py install"
SETUP_STATIC_CMD="$SETUP_CMD --static"
echo ".. Running $SETUP_STATIC_CMD..."
$SETUP_STATIC_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running '$SETUP_STATIC_CMD'."
    exit 1
fi


# Build the Xcode project
((STEP++))
echo "$STEP/$STEPS. Building the Xcode project..."
KA_LITE_PROJECT_DIR="$SCRIPTPATH/KA-Lite"
if [ -d "$KA_LITE_PROJECT_DIR" ]; then
    # MUST: xcodebuild needs to be on the same directory as the .xcodeproj file
    cd "$KA_LITE_PROJECT_DIR"
    xcodebuild clean build
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Running \"xcodebuild clean build\" failed!"
        exit 1
    fi
fi
# check if build of Xcode project succeeded
KA_LITE_APP_PATH="$KA_LITE_PROJECT_DIR/build/Release/KA-Lite.app"
if ! [ -d "$KA_LITE_APP_PATH" ]; then
    echo ".. Abort!  Build of '$KA_LITE_APP_PATH' failed!"
    exit 1
fi


# Check if to codesign or not
((STEP++))
echo "$STEP/$STEPS. Checking if to codesign the application or not..."
SIGNER_IDENTITY_APPLICATION="Developer ID Application: Foundation for Learning Equality, Inc. (H83B64B6AV)"
if [ -z ${IS_BAMBOO+0} ]; then 
    echo ".. Running on local machine, don't codesign the application!"
else 
    echo ".. Running on bamboo server, so MUST codesign the application..."
    # sign the .app file
    # unlock the keychain first so we can access the private key
    # security unlock-keychain -p $KEYCHAIN_PASSWORD
    codesign -d -s "$SIGNER_IDENTITY_APPLICATION" --force "$KA_LITE_APP_PATH"
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Error/s encountered codesigning '$KA_LITE_APP_PATH'."
        exit 1
    fi
fi


# Build the KA-Lite  installer using `Packages` to generate the .pkg file.
((STEP++))
cd "$WORKING_DIR/.."
OUTPUT_PATH="$WORKING_DIR/output"
echo "$STEP/$STEPS. Building the .pkg file at '$OUTPUT_PATH'..."
test ! -d "$OUTPUT_PATH" && mkdir "$OUTPUT_PATH"

KALITE_PACKAGES_NAME="KA-Lite.pkg"
PACKAGES_PROJECT="$SCRIPTPATH/KA-Lite-Packages/KA-Lite.pkgproj"
PACKAGES_OUTPUT="$SCRIPTPATH/KA-Lite-Packages/build/$KALITE_PACKAGES_NAME"

$PACKAGES_EXEC $PACKAGES_PROJECT
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error building the .pkg file with '$PACKAGES_EXEC'."
    exit 1
fi

echo ".. Checking if to productsign the package or not..."
OUTPUT_PKG="$OUTPUT_PATH/$KALITE_PACKAGES_NAME"
SIGNER_IDENTITY_INSTALLER="Developer ID Installer: Foundation for Learning Equality, Inc. (H83B64B6AV)"
if [ -z ${IS_BAMBOO+0} ]; then 
    echo ".. Running on local machine, don't productsign the package!"
    mv -v $PACKAGES_OUTPUT $OUTPUT_PATH
else 
    echo ".. Running on bamboo server, so MUST productsign the package..."
    # sign the .pkg file
    productsign --sign "$SIGNER_IDENTITY_INSTALLER" "$PACKAGES_OUTPUT" "$OUTPUT_PKG"
    if [ $? -ne 0 ]; then
        echo ".. Abort!  Error/s encountered productsigning '$PACKAGES_OUTPUT'."
        exit 1
    fi
fi

echo "Congratulations! Your newly built installer is at '$OUTPUT_PKG'."

# TODO(cpauya): Check https://github.com/learningequality/ka-lite/pull/4630#issuecomment-155567771 for running kalite twice to start.

# TODO(cpauya): To run KA-Lite on the terminal for testing, run the following:
# ./temp/pyrun-2.7/bin/kalite manage syncdb --noinput;
# ./temp/pyrun-2.7/bin/kalite manage setup --noinput;
# ./temp/pyrun-2.7/bin/kalite start;


cd "$WORKING_DIR/.."
echo "Done!"
