Debian installer
================

The Debian installer is based on [stdeb](https://github.com/astraw/stdeb) which
is a tool that automatically converts a normal *setup.py*-based package to a
Debian package structure. There are two equivilent ways of installing KA Lite:

  1. `pip install ka-lite-static` -- installs KA Lite from PyPi with all dependencies builtin ("static").
  1. `dpkg -i NAME_OF_PACKAGE.deb` - installs KA Lite from a Debian package.

The Debian package essentially uses the same distribution script (setup.py)
as the other installers and hence does as little platform-specific work as
possible.

Notice that `setup.py` is run while BUILDING the .deb and not while installing
the .deb.


Normality: How to create an updated .deb:
-----------------------------------------

Say there is a change and you wish to update our sources, here's what you do:

  1. Assumption: The latest release of KA Lite is already on PyPi !
  1. Make sure you have the PPA of our sources: `sudo apt-add-repository --enable-source ppa:benjaoming/ka-lite`
  1. Go to a new directory, `my_code/ka-lite-debian`
  1. Fetch the source package "apt-get source ka-lite"
  1. Fetch a python sdist source tarball of the updated version: https://pypi.python.org/pypi/ka-lite-static
  1. `cd ka-lite-source-x.x/`
  1. `uupdate -v NEW_VERSION ../ka-lite-static-x.x.tar.gz` where NEW_VERSION is a DEBIAN formatted version. 0.14a1 becomes 0.14~a1.
     This is important because it decides package order. If your version isn't considered strictly greater
     than the previous version, Launchpad will reject it.
  1. Run `dch` and add new comment about the update -- remember to use a valid email for PGP signing
  1. Run `dpkg-buildpackage -S` to build new sources, they will be located in the parent dir and signed
  1. Use `dput ppa:learningequality/ka-lite blahblah.changes` to upload to Launchpad



Historic notes - Reproducing the build technique
------------------------------------------------

**Requirements**

  1. stdeb - `pip install stdeb`
  1. setuptools - If you have pip, you have it :)

**Building / developing**

  1. From the root example (the one containing setup.py), link your ka-lite source tree.
  1. Run `./build.sh` which does the following:
     1. Invokes `py2dsc`, then either choose (at the end of the build):
        * Build your own unsigned .deb for all architectures
        * Create and sign a new PPA for benjaoming's Launchpad PPA

**Signing**

Everything is signed with benjaoming's PGP.

**Resources:**

 - [Python Packaging on Debian's wiki](https://wiki.debian.org/Python/Packaging)
 - [Python Library Style Guide](https://wiki.debian.org/Python/LibraryStyleGuide)
 - [Python distutils on MANIFEST files](https://docs.python.org/2/distutils/sourcedist.html#manifest)
 - [Python distutils on installing package data](https://docs.python.org/2/distutils/setupscript.html#distutils-installing-package-data)
 - [Python setuptools "Including data files"](https://pythonhosted.org/setuptools/setuptools.html#including-data-files)
 - [stdeb documentation](https://pypi.python.org/pypi/stdeb) - The library that
   converts our distutils configuration into a debian-like environment
   automatically!

Choices
------------------

 - **Python 2.7** requirement has been chosen because we do not expect systems
   to be running on lower versions of Python anymore, and we need this to
   eventually convert to Python 3 down the road.
 - Everything is done through a debian-specific setup.py file using setuptools,
   and this should work even without the .deb configuration. This is the
   basis of having a workable .deb


Setuptools vs distutils
-----------------------

It would be really great to be packaging with Python was easy, however it's not.

It's therefore very important to highlight:

**THIS PACKAGING EFFORT IS USING SETUPTOOLS AND NOT DISTUTILS!!!**


Wheel
-----

Because of problems with the way that Wheel handles data files, we are not currently using it. bdist_wheel raises an exception for that purpose.


Success criteria
----------------

 * Should be installable in a virtualenv <- This means that we can't just put
   files in system-wide directories by default.
