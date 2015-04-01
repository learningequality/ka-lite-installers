#!/bin/bash
#
# Package script for KA-Lite on PyRun
#
# Steps
# 1. Create temporary directory
# 2. Download the `install-pyrun` script
# 3. Download PyRun thru `install-pyrun` script.
# 4. Download KA-Lite zip based on develop branch.
# 5. Extract KA-Lite and move into `ka-lite` folder.
# 6. Run pyrun-2.7/bin/pip install -r ka-lite/requirements.txt
# 7. Create the `<Xcode_Resources>/ka-lite/kalite/local_settings.py` based on `local_settings.default`.
# 8. Copy the `ka-lite` and `pyrun` folders to the Xcode Resources folder.
# 9. Build the Xcode project.
#
# TODO(cpauya):
# * use `tempfile.py` instead of mktemp which is "subject to race conditions"

# References:
# 1. REF: http://stackoverflow.com/questions/1371351/add-files-to-an-xcode-project-from-a-script

# REF: http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
if [ -z ${TMPDIR+0} ]; then
    echo "$TMPDIR is not set..."
    exit 1
fi

STEP=1
STEPS=9

# TODO(cpauya): This works but the problem is it creates the temporary directory everytime 
# script is run... so during devt, we will comment this for now.
# Create temporary directory.
echo "$STEP/$STEPS. Creating temporary directory..."
# BASE_DIR=`basename $0`
# WORKING_DIR=`mktemp -d -t ${BASE_DIR}` || exit 1
# if [ $? -ne 0 ]; then
#   echo "  $0: Can't create temp directory, exiting..."
#   exit 1
# fi

# TODO(cpauya): Delete when done debugging.  No time to wait for downloads, let's re-use what we have.
WORKING_DIR="."

KA_LITE_MONITOR_PROJECT_DIR="./KA-Lite Monitor"
KA_LITE_MONITOR_DIR="$KA_LITE_MONITOR_PROJECT_DIR/KA-Lite Monitor"
KA_LITE_MONITOR_RESOURCES_DIR="$KA_LITE_MONITOR_DIR/Resources"
KA_LITE_MONITOR_BUILD_PATH="$KA_LITE_MONITOR_PROJECT_DIR/build/Release/KA-Lite Monitor.app"

INSTALL_PYRUN="$WORKING_DIR/install-pyrun.sh"
PYRUN_DIR="$WORKING_DIR/pyrun-2.7"
PYRUN="$PYRUN_DIR/bin/pyrun"
PYRUN_PIP="$PYRUN_DIR/bin/pip"
KA_LITE="ka-lite"
KA_LITE_ZIP="$WORKING_DIR/$KA_LITE.zip"
KA_LITE_DIR="$WORKING_DIR/$KA_LITE"
KA_LITE_REPO_ZIP="https://github.com/learningequality/ka-lite/zipball/develop/"
KA_LITE_EXECUTABLE="$KA_LITE_MONITOR_RESOURCES_DIR/$KA_LITE/kalite/bin/kalite"

LOCAL_SETTINGS_DEFAULT_PATH="$KA_LITE_MONITOR_DIR/local_settings.default"
LOCAL_SETTINGS_TARGET_PATH="$KA_LITE_DIR/kalite/local_settings.py"

echo "  Using temporary directory $WORKING_DIR..."

# Install PyRun.
# REF: http://askubuntu.com/questions/385528/how-to-increment-a-variable-in-bash#385532
((STEP++))
echo "$STEP/$STEPS. Downloading 'install-pyrun' script..."
if [ -e "$INSTALL_PYRUN" ]; then
    echo "  Found '$INSTALL_PYRUN' so will not re-download.  Delete this file to re-download."
else
    curl https://downloads.egenix.com/python/install-pyrun > $INSTALL_PYRUN
    chmod +x $INSTALL_PYRUN
    if [ $? -ne 0 ]; then
      echo "  $0: Can't download 'install-pyrun' script, exiting..."
      exit 1
    fi
fi

# Download PyRun.
((STEP++))
echo "$STEP/$STEPS. Downloading PyRun with Python 2.7..."
if [ -d "$PYRUN_DIR" ]; then
    echo "  Found PyRun directory at '$PYRUN_DIR' so will not re-download.  Delete this folder to re-download."
else
    $INSTALL_PYRUN --python=2.7 $PYRUN_DIR
    if [ $? -ne 0 ]; then
      echo "  $0: Can't install minimal PyRun, exiting..."
      exit 1
    fi
fi

# Get KA-Lite repo
((STEP++))
echo "$STEP/$STEPS. Downloading '$KA_LITE_ZIP' file from '$KA_LITE_REPO_ZIP'..."
if [ -e "$KA_LITE_ZIP" ]; then
	echo "  Found '$KA_LITE_ZIP' file so will not re-download.  Delete this file to re-download."
else
    # REF: http://stackoverflow.com/a/18222354/84548ƒ®1
    # How to download source in .zip format from GitHub?
    # TODO(cpauya): Download from `master` branch NOT from `develop`.
    curl -L -o $KA_LITE_ZIP $KA_LITE_REPO_ZIP
    if [ $? -ne 0 ]; then
      echo "  $0: Can't download 'ka-lite' source, exiting..."
      exit 1
    fi
fi

# Extract KA-Lite
((STEP++))
echo "$STEP/$STEPS. Extracting '$KA_LITE_ZIP'..."
if [ -d "$KA_LITE_DIR" ]; then
	echo "  Found ka-lite directory '$KA_LITE_DIR' so will not extract."
else
    tar -xf $KA_LITE_ZIP
    if [ $? -ne 0 ]; then
      echo "  $0: Can't extract '$KA_LITE_ZIP', exiting..."
      exit 1
    fi
    # Rename the extracted folder.
    mv learningequality* $KA_LITE_DIR
fi

# Create a `ka-lite/kalite/local_settings.py`
((STEP++))
echo "$STEP/$STEPS. Creating '$LOCAL_SETTINGS_TARGET_PATH' from '$LOCAL_SETTINGS_DEFAULT_PATH'..."
cp "$LOCAL_SETTINGS_DEFAULT_PATH" "$LOCAL_SETTINGS_TARGET_PATH"

# Run PyRun's pip install for `requirements.txt`
((STEP++))
echo "$STEP/$STEPS. Running 'pip install -r requirements.txt'... on '$KA_LITE_DIR' "
$PYRUN_PIP install -r "$KA_LITE_DIR/requirements.txt"

# Copy the extracted folders to the Xcode Resources folder
((STEP++))
echo "$STEP/$STEPS. Copy extracted folders to the Xcode Resources folder."
if ! [ -d "$KA_LITE_MONITOR_RESOURCES_DIR" ]; then
    mkdir "$KA_LITE_MONITOR_RESOURCES_DIR"
    echo "  Created Xcode Resources folder..."
fi
# Copy ka-lite...
echo "  cp $KA_LITE_DIR $KA_LITE_MONITOR_RESOURCES_DIR"
cp -R "$KA_LITE_DIR" "$KA_LITE_MONITOR_RESOURCES_DIR"
# Copy pyrun...
echo "  cp $PYRUN_DIR $KA_LITE_MONITOR_RESOURCES_DIR"
cp -R "$PYRUN_DIR" "$KA_LITE_MONITOR_RESOURCES_DIR"

# Build the Xcode project.
((STEP++))
echo "$STEP/$STEPS. Building the Xcode project to $KA_LITE_MONITOR_BUILD_PATH..."
if [ -d "$KA_LITE_MONITOR_PROJECT_DIR" ]; then
    pwd
    cd "$KA_LITE_MONITOR_PROJECT_DIR"
    pwd
    xcodebuild clean build
    cd ..
fi

# Clean-up
# TODO(cpauya): 
if [ $WORKING_DIR != '.' ]; then
    # rmdir -rf "$WORKING_DIR"
    echo "  Removing temporary directory '$WORKING_DIR'..."
    rm -rf "$WORKING_DIR"
fi

echo "Done!"
echo "You can now test the built app at $KA_LITE_MONITOR_BUILD_PATH."