#!/usr/bin/env bash
# **************************************************
# Debian build script for docker

# What does this script do?
#   1. Check if docker is installed.
#   2. Build the docker image.
#   3. Create a docker build tag.
#   4. Run docker-entrypoint.sh script in the docker image.
#   5. Display the newly built installer in the $APP_DIR.

APP_DIR="/installers"
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
WORKING_DIR="$SCRIPTPATH/temp"

STEP=0
STEPS=4

((STEP++))
echo "$STEP/$STEPS. Checking if requirements are installed..."

DOCKER_EXEC="docker"
if ! command -v $DOCKER_EXEC >/dev/null 2>&1; then
    echo ".. Abort! '$DOCKER_EXEC' is not installed."
    exit 1
fi

if ! [ -d "$SCRIPTPATH/temp" ]; then
    echo ".. Creating temporary directory named '$WORKING_DIR'..."
    mkdir "$WORKING_DIR"
fi

((STEP++))
echo "$STEP/$STEPS. Now executing docker image and docker build --tag ..."
docker build --tag debian_build .
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered creating build tag ."
    exit 1
fi

((STEP++))
echo "$STEP/$STEPS. Now running docker-entrypoint.sh ..."
docker run -v $SCRIPTPATH/temp/installers:/installers -it debian_build /bin/bash /docker-entrypoint.sh
if [ $? -ne 0 ]; then
    echo ".. Abort!  Error/s encountered running docker-entrypoint.sh ."
    exit 1
fi

echo "Congratulations! Your newly built installer is at '$WORKING_DIR/temp/$APP_DIR'."
docker run -v $SCRIPTPATH/temp/installers:/installers -it debian_build ls $APP_DIR
echo "Done!"