#!/bin/bash
#
# Install eGenix PyRun in a given target directory.
#
HELP="
Install eGenix PyRun in a given target directory.

USAGE:
       install-pyrun [options] targetdir

OPTIONS:
       -m or --minimal
           install eGenix PyRun only (no setuptools and pip)
       -l of --log
           log installation to targetdir/pyrun-installation.log
       -q or --quiet
           quiet installation

       --python=2.7
           install PyRun for Python version 2.6, 2.7 (default), 3.4
       --python-unicode=ucs2
           install PyRun for Python Unicode version 
           ucs2 (default for Python 2) or ucs4 (default for Python 3)
       --pyrun=2.0.1
           install PyRun version 2.0.1 (default)

       --platform=linux-i686
           install PyRun for the given platform; this is usually
           auto-detected
       --platform-list
           list available platform strings

       --pyrun-distribution=pyrun.tgz
           use the given PyRun distribution file; this overrides
           all other distribution selection parameters
       --pyrun-executable=pyrun
           symlink to and use an alternative name for the PyRun
           executable

       --setuptools-distribution=setuptools.tgz
           use the given setuptools distribution file instead of
           downloading it from PyPI
       --setuptools-version=2.1
           install the setuptools 2.1 (default); use
           --setuptools-version=latest to automatically find the
           latest version on PyPI
       --distribute-distribution=distribute.tgz
           alias for --setuptools-distribution

       --pip-distribution=pip.tgz
           use the given pip distribution file instead of
           downloading it from PyPI
       --pip-version=1.4.1
           install the pip 1.4.1 (default); use --pip-version=latest
           to automatically find the latest version on PyPI

       --help
           show this text
       --version
           show the script version
       --copyright
           show copyright
       --debug
           enable debug output
       --disable-certificate-checks
           disable certificate checks when downloading packages;
           this should normally not be needed

Without options, the script installs eGenix PyRun, setuptools and pip
in targetdir. If no local versions of setuptools or pip are found, the
tools are downloaded from pypi.python.org.
"
COPYRIGHT="
Copyright (c) 2012-2014, eGenix.com Software GmbH; mailto:info@egenix.com

                     All Rights Reserved.

This software may be used under the conditions and terms of the
eGenix.com Public License Agreement. You should have received a
copy with this software (usually in the file LICENSE
located in the package's main directory). Please write to
licenses@egenix.com to obtain a copy in case you should not have
received a copy.
"

# Script version
VERSION=1.2.1

# Generate debug output ?
DEBUG=0

# List of available platform binaries
PLATFORM_LIST="\
linux-x86_64
linux-i686
linux-armv6l
freebsd-8.3-RELEASE-p3-amd64
freebsd-8.3-RELEASE-p3-i386
macosx-10.4-fat
macosx-10.5-x86_64
"

### Configuration

# Select Python version (major.minor)
PYTHON_VERSION=2.7

# Select Python Unicode version (ucs2 or ucs4 depending on
# Python version)
PYTHON_UNICODE_VERSION=

# Select PyRun version (major.minor.patch)
PYRUN_VERSION=2.0.1

# Platform string on the PyRun binary distribution (usually
# auto-detected, see below)
PLATFORM=

# PyRun distribution file. This may contain path information and is
# set from the above configuration parameters, if not given explicitly
# via --pyrun-distribution=
PYRUN_DISTRIBUTION=

# Local PyRun distribution directory to search in
LOCAL_PYRUN_DISTRIBUTION_DIR=/downloads/egenix

# Local PyRun executable name to use
PYRUN_EXECUTABLE=pyrun
#PYRUN_EXECUTABLE=python

# Local setuptools distribution to search for
SETUPTOOLS_VERSION=2.1
LOCAL_SETUPTOOLS_DISTRIBUTION_DIR=/downloads/python/setuptools

# Local pip distribution to search for
PIP_VERSION=1.4.1
LOCAL_PIP_DISTRIBUTION_DIR=/downloads/python/pip

### Parse options

INSTALL_SETUPTOOLS=1
INSTALL_PIP=1
LOG_INSTALLATION=0
RUN_SILENT=0
VERBOSITY=0
DISABLE_CERTIFICATE_CHECKS=0
for i; do
    arg=$i
    while [ -n $arg ]; do
	case $arg in
	    - )
		break
		;;

	    # Short options (can be comined, e.g. -mq)
	    -m* )
		INSTALL_SETUPTOOLS=0
		INSTALL_PIP=0
		arg="-"${arg:2}
		;;
	    -q* )
		RUN_SILENT=1
		arg="-"${arg:2}
		;;
	    -l* )
		LOG_INSTALLATION=1
		arg="-"${arg:2}
		;;
	    -h )
		# Note: The quotes are important to make sure the
		# newlines are interpreted correctly
		echo "$HELP"
		exit 0
		;;

	    # Long options
	    --minimal )
		INSTALL_SETUPTOOLS=0
		INSTALL_PIP=0
		break
		;;
	    --log )
		LOG_INSTALLATION=1
		break
		;;
	    --quiet )
		RUN_SILENT=1
		break
		;;
	    --help )
		# Note: The quotes are important to make sure the
		# newlines are interpreted correctly
		echo "$HELP"
		exit 0
		;;

	    # Long-only options
	    --python=* )
		PYTHON_VERSION=${arg:9}
		break
		;;
	    --python-unicode=* )
		PYTHON_UNICODE_VERSION=${arg:17}
		break
		;;
	    --pyrun=* )
		PYRUN_VERSION=${arg:8}
		break
		;;
	    --platform=* )
		PLATFORM=${arg:11}
		break
		;;
	    --platform-list )
	        echo "Available platform strings:"
		echo "---------------------------"
		echo "$PLATFORM_LIST"
		exit 0
		break
		;;
	    --pyrun-distribution=* )
	        # Note: We use eval here to deal with tilde expansions
	        # and the like
		eval PYRUN_DISTRIBUTION=${arg:21}
		break
		;;
	    --pyrun-executable=* )
	        # Note: We use eval here to deal with tilde expansions
	        # and the like
		eval PYRUN_EXECUTABLE=${arg:19}
		break
		;;
	    --setuptools-distribution=*|--distribute-distribution=* )
	        # Note: We use eval here to deal with tilde expansions
	        # and the like
		eval SETUPTOOLS_DISTRIBUTION=${arg:26}
		break
		;;
	    --setuptools-version=* )
		SETUPTOOLS_VERSION=${arg:21}
		break
		;;
	    --pip-distribution=* )
	        # Note: We use eval here to deal with tilde expansions
	        # and the like
		eval PIP_DISTRIBUTION=${arg:19}
		break
		;;
	    --pip-version=* )
		PIP_VERSION=${arg:14}
		break
		;;
	    --disable-certificate-checks )
		DISABLE_CERTIFICATE_CHECKS=1
		break
		;;
	    --version )
		echo "install-pyrun $VERSION"
		exit 0
		;;
	    --copyright )
		echo "$COPYRIGHT"
		exit 0
		;;
	    --debug )
		DEBUG=1
		break
		;;
	    # Unknown option
	    -* )
		echo "Unknown option: $arg"
		exit 1
		;;
	    # First non-option argument
	    * )
	        # Note: We use eval here to deal with tilde expansions
	        # and the like
		eval INSTALLATION_DIR=$i
		break 2
		;;
	esac
    done
done

# Installation directory
if [ -z "$INSTALLATION_DIR" ]; then
    echo "$HELP"
    exit 1
fi

### Helpers

# Current work dir
CWD=`pwd`

# Tools
TAR=tar
LN=ln
MKDIR=mkdir
CURL=`command -v curl`
CURL_OPTIONS="-Ssf"
CURL_FILE_OPTIONS="-O"
CURL_STDOUT_OPTIONS="-o -"
WGET=`command -v wget`
WGET_OPTIONS=
WGET_FILE_OPTIONS=
WGET_STDOUT_OPTIONS="-O -"
RM=rm
ECHO=echo

# Detect platform, if not given
if [ -z "$PYTHON_UNICODE_VERSION" ]; then
    if [[ "$PYTHON_VERSION" < "3" ]]; then
        # Python 2 default
        PYTHON_UNICODE_VERSION="ucs2"
    else
        # Python 3 default
        PYTHON_UNICODE_VERSION="ucs4"
    fi
fi

# Certificate checks
if (( $DISABLE_CERTIFICATE_CHECKS )); then
    CURL_OPTIONS="-k $CURL_OPTIONS"
    WGET_OPTIONS="--no-check-certificate $WGET_OPTIONS"
fi

# Convert to absolute path
case "$INSTALLATION_DIR" in
    /*) ;;
    *) INSTALLATION_DIR=$CWD/$INSTALLATION_DIR
esac

# Log file
if (( $LOG_INSTALLATION )); then
    LOG_FILE=$INSTALLATION_DIR/pyrun-installation.log
else
    LOG_FILE=/dev/null
fi
if (( $RUN_SILENT )); then
    LOG_FILE=/dev/null
    ECHO=true
fi

# Fetch URL tool
if [ -e "$CURL" ]; then
    FETCHURL="$CURL $CURL_OPTIONS $CURL_FILE_OPTIONS "
    READURL="$CURL $CURL_OPTIONS $CURL_STDOUT_OPTIONS "
elif [ -e "$WGET" ]; then
    FETCHURL="$WGET $WGET_OPTIONS $WGET_FILE_OPTIONS "
    READURL="$WGET $WGET_OPTIONS $WGET_STDOUT_OPTIONS "
else
    echo "Could not find curl or wget. Please consider installing one of those tools."
    FETCHURL=
    READURL=
fi

# Detect platform, if not given
if [ -z "$PLATFORM" ]; then
    PLATFORM_SYSTEM=`uname -s`
    PLATFORM_PROCESSOR=`uname -p`
    if [[ "$PLATFORM_PROCESSOR" -eq "unknown" ]]; then
	PLATFORM_PROCESSOR=`uname -m`
    fi
    # When updating this list, please also update the PLATFORM_LIST
    # variable further up.
    case "$PLATFORM_SYSTEM $PLATFORM_PROCESSOR" in
        Linux\ x86_64 )
            PLATFORM=linux-x86_64
            ;;
        Linux\ i?86 )
            PLATFORM=linux-i686
            ;;
        Linux\ armv6l )
	    # Raspberry Pi
            PLATFORM=linux-armv6l
            ;;
        FreeBSD\ amd64 )
            PLATFORM=freebsd-8.3-RELEASE-p3-amd64
            ;;
        FreeBSD\ i386 )
            PLATFORM=freebsd-8.3-RELEASE-p3-i386
            ;;
        Darwin\ powerpc )
            PLATFORM=macosx-10.4-fat
            ;;
        Darwin\ i386 )
            OS_VERSION=`uname -r`
            if (( ${OS_VERSION%%.*} < 10 )); then
                # Leopard and earlier default to 32-bit applications
                PLATFORM=macosx-10.4-fat
            else
                # Snow Leopard and later can run 64-bit applications
                PLATFORM=macosx-10.5-x86_64
            fi
            ;;
        Darwin\ x86_64 )
            PLATFORM=macosx-10.5-x86_64
            ;;
        * )
            echo "Unknown platform \"$PLATFORM_SYSTEM $PLATFORM_PROCESSOR\". Please set manually using --platform=..."
            exit 1
            ;;
    esac
fi

# Double check Python compatibility
#
# Python 2.5 are no longer needed for eGenix PyRun 2.0, since
# we don't support it anymore for 2.0. Leaving this code in
# to be able to install older pyrun versions as well.
#
if [ "$PYTHON_VERSION" == "2.5" ]; then
    # setuptools dropped Python 2.5 support in setuptools 2.0, so
    # force to use the last compatible setuptools version
    if [[ "$SETUPTOOLS_VERSION" > "1.4.2" ]]; then
	echo "WARNING: setuptools $SETUPTOOLS_VERSION is not compatible with Python 2.5; using setuptools 1.4.2" 2>&1 | tee -a $LOG_FILE
	SETUPTOOLS_VERSION="1.4.2"
    fi
    # pip dropped Python 2.5 support in pip 1.4, so force to 
    # use the last compatible pip version
    if [[ "$PIP_VERSION" > "1.3.1" ]]; then
	echo "WARNING: pip $PIP_VERSION is not compatible with Python 2.5; using pip 1.3.1" 2>&1 | tee -a $LOG_FILE
	PIP_VERSION="1.3.1"
    fi
fi

# eGenix PyRun distribution to use
if [ -z "$PYRUN_DISTRIBUTION" ]; then
    PYRUN_DISTRIBUTION=egenix-pyrun-$PYRUN_VERSION-py${PYTHON_VERSION}_$PYTHON_UNICODE_VERSION-$PLATFORM.tgz
fi

# Local distribution file name (use PYRUN_DISTRIBUTION if it exists,
# fall back to LOCAL_PYRUN_DISTRIBUTION_DIR otherwise)
if ([ -e $PYRUN_DISTRIBUTION ]); then
    LOCAL_PYRUN_DISTRIBUTION=$PYRUN_DISTRIBUTION
else
    LOCAL_PYRUN_DISTRIBUTION=$LOCAL_PYRUN_DISTRIBUTION_DIR/$PYRUN_DISTRIBUTION
fi

# Convert to absolute path
case "$LOCAL_PYRUN_DISTRIBUTION" in
    /*) ;;
    *) LOCAL_PYRUN_DISTRIBUTION=$CWD/$LOCAL_PYRUN_DISTRIBUTION
esac

# Remote distribution URL (this is only used in case no local
# distribution file can be found)
REMOTE_PYRUN_DISTRIBUTION=https://downloads.egenix.com/python/$PYRUN_DISTRIBUTION

# setuptools package on PyPI
SETUPTOOLS_JSON_URL="https://pypi.python.org/pypi/setuptools/json"
SETUPTOOLS_RE="https://pypi.python.org/packages/source/s/setuptools/setuptools-[0-9\.]+\.tar\.gz"
SETUPTOOLS_DOWNLOAD_URL="https://pypi.python.org/packages/source/s/setuptools/setuptools-${SETUPTOOLS_VERSION}.tar.gz"

# setuptools distribution to use
if [[ -z "$SETUPTOOLS_DISTRIBUTION" ]]; then
    SETUPTOOLS_DISTRIBUTION=setuptools-$SETUPTOOLS_VERSION.tar.gz
fi

# Local distribution file name for setuptools
if ([ -e $SETUPTOOLS_DISTRIBUTION ]); then
    LOCAL_SETUPTOOLS_DISTRIBUTION=$SETUPTOOLS_DISTRIBUTION
else
    LOCAL_SETUPTOOLS_DISTRIBUTION=$LOCAL_SETUPTOOLS_DISTRIBUTION_DIR/$SETUPTOOLS_DISTRIBUTION
fi

# Convert to absolute path
case "$LOCAL_SETUPTOOLS_DISTRIBUTION" in
    /*) ;;
    *) LOCAL_SETUPTOOLS_DISTRIBUTION=$CWD/$LOCAL_SETUPTOOLS_DISTRIBUTION
esac

# pip package on PyPI
PIP_JSON_URL="https://pypi.python.org/pypi/pip/json"
PIP_RE="https://pypi.python.org/packages/source/p/pip/pip-[0-9\.]+\.tar\.gz"
PIP_DOWNLOAD_URL="https://pypi.python.org/packages/source/p/pip/pip-${PIP_VERSION}.tar.gz"

# pip distribution to use
if [[ -z "$PIP_DISTRIBUTION" ]]; then
    PIP_DISTRIBUTION=pip-$PIP_VERSION.tar.gz
fi

# Local distribution file name for pip
if ([ -e $PIP_DISTRIBUTION ]); then
    LOCAL_PIP_DISTRIBUTION=$PIP_DISTRIBUTION
else
    LOCAL_PIP_DISTRIBUTION=$LOCAL_PIP_DISTRIBUTION_DIR/$PIP_DISTRIBUTION
fi

# Convert to absolute path
case "$LOCAL_PIP_DISTRIBUTION" in
    /*) ;;
    *) LOCAL_PIP_DISTRIBUTION=$CWD/$LOCAL_PIP_DISTRIBUTION
esac

# Debug output
if (( DEBUG )); then
    $ECHO "Using the following PyRun installation settings:"
    $ECHO "  PYRUN_VERSION=${PYRUN_VERSION}"
    $ECHO "  PYTHON_VERSION=${PYTHON_VERSION}"
    $ECHO "  PYTHON_UNICODE_VERSION=${PYTHON_UNICODE_VERSION}"
    $ECHO "  PYRUN_DISTRIBUTION=${PYRUN_DISTRIBUTION}"
    $ECHO "  LOCAL_PYRUN_DISTRIBUTION=${LOCAL_PYRUN_DISTRIBUTION}"
    $ECHO "  REMOTE_PYRUN_DISTRIBUTION=${REMOTE_PYRUN_DISTRIBUTION}"
    $ECHO "  SETUPTOOLS_DISTRIBUTION=${SETUPTOOLS_DISTRIBUTION}"
    $ECHO "  SETUPTOOLS_VERSION=${SETUPTOOLS_VERSION}"
    $ECHO "  SETUPTOOLS_JSON_URL=${SETUPTOOLS_JSON_URL}"
    $ECHO "  LOCAL_SETUPTOOLS_DISTRIBUTION=${LOCAL_SETUPTOOLS_DISTRIBUTION}"
    $ECHO "  PIP_VERSION=${PIP_VERSION}"
    $ECHO "  PIP_DISTRIBUTION=${PIP_DISTRIBUTION}"
    $ECHO "  PIP_JSON_URL=${PIP_JSON_URL}"
    $ECHO "  LOCAL_PIP_DISTRIBUTION=${LOCAL_PIP_DISTRIBUTION}"
    $ECHO "  INSTALLATION_DIR=${INSTALLATION_DIR}"
    $ECHO "  FETCHURL=${FETCHURL}"
fi

### Installation

# Run installation in the INSTALLATION_DIR
$MKDIR -p $INSTALLATION_DIR
cd $INSTALLATION_DIR
touch $LOG_FILE

# Install PyRun
if [ ! -e $LOCAL_PYRUN_DISTRIBUTION ]; then
    $ECHO "Downloading eGenix PyRun ..." 2>&1 | tee -a $LOG_FILE
    $FETCHURL $REMOTE_PYRUN_DISTRIBUTION >> $LOG_FILE 2>&1
    rc=$?
    if (( $rc )); then
	echo "Failed to download $REMOTE_PYRUN_DISTRIBUTION"
	exit $rc
    fi
    $ECHO "" >> $LOG_FILE 2>&1
    $ECHO "Installing eGenix PyRun ..." 2>&1 | tee -a $LOG_FILE
    $TAR -x -v -z -f $PYRUN_DISTRIBUTION >> $LOG_FILE 2>&1
    rc=$?
    if (( $rc )); then
	echo "Failed to extract $PYRUN_DISTRIBUTION"
	exit $rc
    fi
    $RM -f $PYRUN_DISTRIBUTION
else
    $ECHO "Installing eGenix PyRun ..." 2>&1 | tee -a $LOG_FILE
    $ECHO "extracting files from $LOCAL_PYRUN_DISTRIBUTION" >> $LOG_FILE 2>&1
    $TAR -x -v -z -f $LOCAL_PYRUN_DISTRIBUTION >> $LOG_FILE 2>&1
    rc=$?
    if (( $rc )); then
	echo "Could not extract $LOCAL_PYRUN_DISTRIBUTION"
	exit $rc
    fi
fi
$ECHO "" >> $LOG_FILE 2>&1

# Add symlink to an alternative name
if [ "$PYRUN_EXECUTABLE" != "pyrun" ]; then
    $ECHO "adding symlink to from bin/pyrun to bin/$PYRUN_EXECUTABLE" >> $LOG_FILE 2>&1
    $LN -sf pyrun bin/$PYRUN_EXECUTABLE >> $LOG_FILE 2>&1
    $ECHO "" >> $LOG_FILE 2>&1
fi

# Install setuptools
if (( $INSTALL_SETUPTOOLS )); then
    if [ ! -e $LOCAL_SETUPTOOLS_DISTRIBUTION ]; then
	if [ "$SETUPTOOLS_VERSION" == "latest" ]; then
	    # Find the URL of the latest setuptools distribution file
	    $ECHO "Installing latest setuptools from PyPI ..." 2>&1 | tee -a $LOG_FILE
	    if (( DEBUG )); then
	    	$ECHO "Available setuptools packages:"
	    	$ECHO "`$READURL -q ${SETUPTOOLS_JSON_URL} | egrep -o ${SETUPTOOLS_RE}`"
	    fi
	    FETCH_SETUPTOOLS_URL=$(\
            $READURL -q ${SETUPTOOLS_JSON_URL} | \
		egrep -o ${SETUPTOOLS_RE} | \
		sed 's/.tar.gz//' | \
		sort -r | \
		head -n 1).tar.gz
	    if [ -z $FETCH_SETUPTOOLS_URL ]; then
		echo "Could not find setuptools on PyPI"
		exit $rc
	    fi
	    $ECHO "Found $FETCH_SETUPTOOLS_URL" 2>&1 | tee -a $LOG_FILE
	else
	    $ECHO "Installing setuptools $SETUPTOOLS_VERSION from PyPI ..." 2>&1 | tee -a $LOG_FILE
	    FETCH_SETUPTOOLS_URL=$SETUPTOOLS_DOWNLOAD_URL
	fi
	$ECHO "Downloading setuptools from $FETCH_SETUPTOOLS_URL ..."  >> $LOG_FILE 2>&1
	$FETCHURL $FETCH_SETUPTOOLS_URL >> $LOG_FILE 2>&1
	rc=$?
	if (( $rc )); then
	    echo "Failed to download $FETCH_SETUPTOOLS_URL"
	    exit $rc
	fi
	$ECHO "Extracting and installing setuptools ..."  >> $LOG_FILE 2>&1
	SETUPTOOLS_FILE=${FETCH_SETUPTOOLS_URL##*/}
	SETUPTOOLS_DIR=${SETUPTOOLS_FILE%.tar.gz}
	$TAR -x -v -z -f $SETUPTOOLS_FILE >> $LOG_FILE 2>&1
	cd $SETUPTOOLS_DIR
	../bin/$PYRUN_EXECUTABLE setup.py install >> $LOG_FILE 2>&1
	rc=$?
	if (( $rc )); then
	    echo "Failed to install setuptools"
	    exit $rc
	fi
	cd ..
	$RM -rf setuptools* >> $LOG_FILE 2>&1
	$ECHO "" >> $LOG_FILE 2>&1
    else
	$ECHO "Installing local setuptools $SETUPTOOLS_VERSION ..." 2>&1 | tee -a $LOG_FILE
	$ECHO "extracting files from $LOCAL_SETUPTOOLS_DISTRIBUTION" >> $LOG_FILE 2>&1
	$TAR -x -v -z -f $LOCAL_SETUPTOOLS_DISTRIBUTION >> $LOG_FILE 2>&1
	rc=$?
	if (( $rc )); then
	    echo "Could not extract $LOCAL_SETUPTOOLS_DISTRIBUTION"
	    exit $rc
	fi
	cd setuptools-*
	../bin/$PYRUN_EXECUTABLE setup.py install >> $LOG_FILE 2>&1
	rc=$?
	cd ..
	if (( $rc )); then
	    echo "Failed to install setuptools"
	    exit $rc
	fi
	$RM -rf setuptools-* >> $LOG_FILE 2>&1
	$ECHO "" >> $LOG_FILE 2>&1
    fi
fi

# Install pip
if (( $INSTALL_PIP )); then
    if [ ! -e $LOCAL_PIP_DISTRIBUTION ]; then
	if [ "$PIP_VERSION" == "latest" ]; then
	    # Find the URL of the latest pip distribution file
	    $ECHO "Installing latest pip from PyPI ..." 2>&1 | tee -a $LOG_FILE
	    if (( DEBUG )); then
	    	$ECHO "Available pip packages:"
	    	$ECHO "`$READURL -q ${PIP_JSON_URL} | egrep -o ${PIP_RE}`"
	    fi
	    FETCH_PIP_URL=$(\
            $READURL -q ${PIP_JSON_URL} | \
		egrep -o ${PIP_RE} | \
		sed 's/.tar.gz//' | \
		sort -r | \
		head -n 1).tar.gz
	    if [ -z $FETCH_PIP_URL ]; then
		echo "Could not find pip on PyPI"
		exit $rc
	    fi
	    $ECHO "Found $FETCH_PIP_URL" 2>&1 | tee -a $LOG_FILE
	else
	    $ECHO "Installing pip $PIP_VERSION from PyPI ..." 2>&1 | tee -a $LOG_FILE
	    FETCH_PIP_URL=$PIP_DOWNLOAD_URL
	fi
	$ECHO "Downloading pip from $FETCH_PIP_URL ..."  >> $LOG_FILE 2>&1
	$FETCHURL $FETCH_PIP_URL >> $LOG_FILE 2>&1
	rc=$?
	if (( $rc )); then
	    echo "Failed to download $FETCH_PIP_URL"
	    exit $rc
	fi
	$ECHO "Extracting and installing pip ..."  >> $LOG_FILE 2>&1
	PIP_FILE=${FETCH_PIP_URL##*/}
	PIP_DIR=${PIP_FILE%.tar.gz}
	$TAR -x -v -z -f $PIP_FILE >> $LOG_FILE 2>&1
	cd $PIP_DIR
	../bin/$PYRUN_EXECUTABLE setup.py install >> $LOG_FILE 2>&1
	rc=$?
	if (( $rc )); then
	    echo "Failed to install pip"
	    exit $rc
	fi
	cd ..
	$RM -rf pip* >> $LOG_FILE 2>&1
	$ECHO "" >> $LOG_FILE 2>&1
    else
	$ECHO "Installing local pip $PIP_VERSION ..." 2>&1 | tee -a $LOG_FILE
	$ECHO "extracting files from $LOCAL_PIP_DISTRIBUTION" >> $LOG_FILE 2>&1
	$TAR -x -v -z -f $LOCAL_PIP_DISTRIBUTION >> $LOG_FILE 2>&1
	rc=$?
	if (( $rc )); then
	    echo "Could not extract $LOCAL_PIP_DISTRIBUTION"
	    exit $rc
	fi
	cd pip-*
	../bin/$PYRUN_EXECUTABLE setup.py install >> $LOG_FILE 2>&1
	rc=$?
	cd ..
	if (( $rc )); then
	    echo "Failed to install pip"
	    exit $rc
	fi
	$RM -rf pip-* >> $LOG_FILE 2>&1
	$ECHO "" >> $LOG_FILE 2>&1
    fi
fi

# Finished
cd ..
$ECHO ""
$ECHO "eGenix PyRun was installed in $INSTALLATION_DIR"
$ECHO ""
$ECHO "To run eGenix PyRun, use $INSTALLATION_DIR/bin/$PYRUN_EXECUTABLE"
$ECHO ""
