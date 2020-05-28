Debian installer
================

How to develop the debian/ sources
----------------------------------

You wouldn't wanna do this with the full KA Lite sources because they
take too much time to build.

Run::

    ./make_test_pkg.sh 1.2.3  # <- notice the version string required
    cd test/ka-lite-test
    debuild -us -uc  # Builds unsigned installable .deb files with no content
    debuild --no-lintian -us -uc  # Skips the lintian checks if you want
    DEBCONF_DEBUG=developer sudo dpkg --debug=3773 -i ../ka-lite_1.2.3_all.deb  # Installs the test package with highest debug level
    sudo dpkg -i ../ka-lite_1.2.3_all.deb  # Installs the test package WITHOUT all the debugging stuff
    cd ../../  # Go back to previous directory
    ./copy_from_pkg.sh  # By default, this command copies from the default test folder


To create a test package in another directory, do::

    ./make_test_pkg.sh path/to/test 1.2.3

If you want to copy the debian sources from another test setup, do::

    ./copy_from_pkg.sh path/to/other/pkg


Regarding the **coding style**, all the so-called "maint" scripts (preinst/postinst/prerm/postrm/config) are
running ``/bin/bash`` and have the ``set -e`` option on. There is a clear intention to be very DRY and
to have loads of comments because many choices reflect tough experiences.

Consider reading this blog post: http://www.davidpashley.com/articles/writing-robust-shell-scripts/


Debugging tips
______________

Use ``set -x`` in bash scripts to enable debugging, it's extremely helpful.

Everything should be compatible with ``set -e``. See: http://www.davidpashley.com/articles/writing-robust-shell-scripts/

Run ``debconf-show ka-lite`` to view the ``ka-lite`` package debconf settings.

How to create an updated .deb for release
-----------------------------------------

Say there is a change and you wish to update our sources, here's what
you do:

1.  Assumption: The latest release of KA Lite is already on PyPi !
2.  Make sure you have the PPA of our sources:
    ``sudo apt-add-repository --enable-source ppa:learningequality/ka-lite``
3.  Go to a new directory, ``my_code/ka-lite-debian``
4.  Fetch the source package "apt-get source ka-lite"
5.  Fetch a python sdist source tarball of the updated version:
    https://pypi.python.org/pypi/ka-lite-static
6.  ``cd ka-lite-source-x.x/``
7.  ``uupdate -v NEW_VERSION ../ka-lite-static-x.x.tar.gz`` where
    NEW\_VERSION is a DEBIAN formatted version. 0.14a1 becomes 0.14~a1.
    This is important because it decides package order. If your version
    isn't considered strictly greater than the previous version,
    Launchpad will reject it.
8.  Run ``dch`` and add new comment about the update -- remember to use
    a valid email for PGP signing
9.  Run ``dpkg-buildpackage -S`` to build new sources, they will be
    located in the parent dir and signed
10. Use ``dput ppa:learningequality/ka-lite blahblah.changes`` to upload
    to Launchpad


Historic notes - Reproducing the build technique
________________________________________________

**Resources:**

-  `Python Packaging on Debian's
   wiki <https://wiki.debian.org/Python/Packaging>`__
-  `Python Library Style
   Guide <https://wiki.debian.org/Python/LibraryStyleGuide>`__
-  `Python distutils on MANIFEST
   files <https://docs.python.org/2/distutils/sourcedist.html#manifest>`__
-  `Python distutils on installing package
   data <https://docs.python.org/2/distutils/setupscript.html#distutils-installing-package-data>`__
-  `Python setuptools "Including data
   files" <https://pythonhosted.org/setuptools/setuptools.html#including-data-files>`__
-  `stdeb documentation <https://pypi.python.org/pypi/stdeb>`__ - The
   library that converts our distutils configuration into a debian-like
   environment automatically!

Choices
-------

-  **Python 2.7** requirement has been chosen because we do not expect
   systems to be running on lower versions of Python anymore, and we
   need this to eventually convert to Python 3 down the road.
-  Everything is done through a debian-specific setup.py file using
   setuptools, and this should work even without the .deb configuration.
   This is the basis of having a workable .deb

Setuptools vs distutils
-----------------------

It would be really great to be packaging with Python was easy, however
it's not.

It's therefore very important to highlight:

**THIS PACKAGING EFFORT IS USING SETUPTOOLS AND NOT DISTUTILS!!!**

Wheel
-----

Because of problems with the way that Wheel handles data files, we are
not currently using it. bdist\_wheel raises an exception for that
purpose.

Success criteria
----------------

-  Should be installable in a virtualenv <- This means that we can't
   just put files in system-wide directories by default.

