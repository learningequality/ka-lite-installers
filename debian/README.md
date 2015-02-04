Debian installer
================

Introduction
------------

**Resources:**

 - [Python Packaging on Debian's wiki](https://wiki.debian.org/Python/Packaging)
 - [Python Library Style Guide](https://wiki.debian.org/Python/LibraryStyleGuide)
 - [Python distutils on MANIFEST files](https://docs.python.org/2/distutils/sourcedist.html#manifest)
 - [Python distutils on installing package data](https://docs.python.org/2/distutils/setupscript.html#distutils-installing-package-data)
 - [stdeb documentation](https://pypi.python.org/pypi/stdeb) - The library that
   converts our distutils configuration into a debian-like environment
   automatically!

Choices
------------------

 - **Python 2.7** requirement has been chosen because we do not expect systems
   to be running on lower versions of Python anymore, and we need this to
   eventually convert to Python 3 down the road.
 - Everything is done through a debian-specific setup.py file using distutils,
   and this should work even without the .deb configuration. This is the
   basis of having a workable .deb

### Directory layout


- `/var/kalite` for everything -- except binaries, data, and kalite python module
- `/var/kalite/djangoproject/` for `settings` and `local_settings`,
  `kalitectl.py`, and `manage.py` (TO BE REMOVED!).
- `/var/kalite/python-packages` -- this should exist in the static deb, and once
  we get our external dependencies sorted out, we can get a dynamic deb as
  well which doesn't include this.
- `/var/kalite/database/` for the database

* Everything in /var/kalite/srv* should be served by a webserver.

- `/var/kalite/srv/media/` for everything in the MEDIA_ROOT.
- `/var/kalite/srv/static/` for everything in the STATIC_ROOT.
- `/var/kalite/srv/content/` for everything in the STATIC_ROOT.
- `/var/kalite/srv/data/` for everything in the STATIC_ROOT.

The main executable:
- `/usr/bin/kalite`

The `kalite` python module will likely end up here:

-  `/usr/lib/pythonX.X/dist-packages/`


Build requirements
------------------

Use apt-get to retrieve the following packages:

- python-stdeb


Building
--------

### Build a normal python sdist tarball

Before creating the Debian package, you can verify that distutils can correctly
build a python package through the setup.py script. This is standard stuff,
but the setup.py file is only (at the moment!) intended to work on a Linux
system.



