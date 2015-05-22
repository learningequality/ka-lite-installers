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


Introduction
------------

**Requirements**

  1. stdeb - `pip install stdeb`
  1. setuptools - If you have pip, you have it :)

**Building / developing**

  1. From the root example (the one containing setup.py), link your ka-lite source tree.
  1. Run `./build_dsc.sh` which does the following:
     1. Invokes `py2dsc`
     1. Builds documentation
     1. Copies documentation to debian source
     1. Builds .deb for all architectures


**Signing**

TODO - we need GPG signing


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


Success criteria
----------------

 * Should be installable in a virtualenv <- This means that we can't just put
   files in system-wide directories by default.