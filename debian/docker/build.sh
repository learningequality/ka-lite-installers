#!/usr/bin/env bash
# **************************************************
# Debian build script for docker

# Steps
#   1. Check if docker is installed.
#   2. Build the docker image.
#   3. Create a docker build tag.
#   4. Run docker-entrypoint.sh script in the docker image.
#   5. Display the newly built installer in the $APP_DIR.

APP_DIR="/ka-lite-source-0.16.6"
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
WORKING_DIR="$SCRIPTPATH/temp"
CP_DEBIAN_FOLDER="cp -R ../debian $WORKING_DIR/$APP_DIR/debian"


STEP=0
STEPS=3

if [ "$1" == "build_ppa" ]; then
    BUILD_OPTION="$1"
else
    BUILD_OPTION="build_local"
fi

((STEP++))
echo "$STEP/$STEPS. Checking if requirements are installed..."

DOCKER_EXEC="docker"
if ! command -v $DOCKER_EXEC >/dev/null 2>&1; then
    echo ".. Abort! '$DOCKER_EXEC' is not installed."
    exit 1
fi

if ! [ -d "$SCRIPTPATH/temp" ]; then
    echo ".. Creating temporary directory named '$WORKING_DIR'..."
    mkdir -p "$WORKING_DIR$APP_DIR"
    
fi

echo "$STEP/$STEPS. Checking if requirements are installed..."
$CP_DEBIAN_FOLDER
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered '$CP_DEBIAN_FOLDER'..."
    exit 1
fi

((STEP++))
echo "$STEP/$STEPS. Now executing docker image and docker build --tag ..."
if [ "$1" == "build_ppa" ]; then
    echo "Now building package source from ppa"
    DOCKER_CMD="docker build --tag debian_build ./$BUILD_OPTION/"
else
    DOCKER_CMD="docker build --tag debian_build ./$BUILD_OPTION/"
fi

$DOCKER_CMD
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered creating build tag ."
    exit 1
fi

((STEP++))
echo "$STEP/$STEPS. Now running docker-entrypoint.sh ..."
docker run -v $SCRIPTPATH/temp/ka-lite-source-0.16.6:/ka-lite-source-0.16.6 -it debian_build /bin/bash /docker-entrypoint.sh
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running docker-entrypoint.sh ."
    exit 1
fi

echo "Congratulations! Your newly built installer is at '$WORKING_DIR$APP_DIR'."
docker run -v $SCRIPTPATH/temp/ka-lite-source-0.16.6:/ka-lite-source-0.16.6 -it debian_build ls $APP_DIR
echo "Done!"

