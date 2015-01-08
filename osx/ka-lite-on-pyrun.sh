#!/bin/bash
#
# Package script for KA-Lite on PyRun
#
# Requirements
# . git
#
# Steps
# . Execute the PyRun installer from https://downloads.egenix.com/python/install-pyrun into a tmp directory.
# . Clone KA-Lite into a directory
# . Create a kalite binary in `/usr/local/bin/` to use PyRun's Python instead of the system Python.
# . Modify `<ka-lite-folder>/python.sh` so it uses PyRun`s Python.

INSTALL_PYRUN="install-pyrun.sh"
PYRUN_DIR="/tmp/ka-lite-on-pyrun"
PYRUN="$PYRUN_DIR/bin/pyrun"

KA_LITE_DIR="$PYRUN_DIR/ka-lite"

# Install PyRun
echo "Downloading PyRun..."
curl https://downloads.egenix.com/python/install-pyrun > $INSTALL_PYRUN
echo "Installing minimal PyRun..."
$INSTALL_PYRUN -m --python=2.7 $PYRUN_DIR

# Checkout KA-Lite
# TODO(cpauya): git clone https://github.com/learningequality/ka-lite.git $KA_LITE_DIR