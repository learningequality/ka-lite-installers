Debian installer
================

How to create an updated .deb for release
-----------------------------------------

If there is a new release of KA Lite and you need to create a new .deb package,
do the following:

#. Prerequisite: The latest release of KA Lite is already on PyPi!
#. Make sure you have the PPA of our sources:

   .. code-block:: bash

      sudo apt-add-repository --enable-source ppa:learningequality/ka-lite

#. Install the build dependencies:

   .. code-block:: bash

      sudo apt build-dep ka-lite
      sudo apt install build-essential devscripts

#. Go to a new working directory and fetch the source package:

   .. code-block:: bash

      # For instance, if you are in ka-lite-installers, you could work in
      # debian/build - it's already in .gitignore
      mkdir -p debian/build
      cd debian/build
      
      # Grab the latest source available
      apt-get source ka-lite

#. Fetch a python sdist source tarball of the updated version:
   https://pypi.python.org/pypi/ka-lite-static

   You can fetch the latest pre-release like this:
   
   .. code-block:: bash

      pip download --no-binary ":all:" --pre ka-lite-static

#. Now change working directory to the Debian source package that was unpacked
   and create a new package, using the Python package that you just downloaded:

   .. code-block:: bash
   
      cd ka-lite-source-x.y/
      uupdate -v NEW_VERSION ../ka-lite-static-x.y.tar.gz
   
   **NB!** ``NEW_VERSION`` is a DEBIAN formatted version. 0.14a1 becomes 0.14~a1.
   This is important because it decides package order. If your version
   isn't considered strictly greater than the previous version,
   Launchpad will reject it.
   
#. Run ``dch`` and add new comment about the update -- remember to use
   a valid email for PGP signing. You should also change ``UNRELEASED`` to
   ``trusty`` as this is the lower bound of our target dist series.

#. Run ``dpkg-buildpackage -S`` to build new sources, they will be
   located in the parent dir and signed.

#. At this stage, before uploading to Launchpad, you may want to try to install
   a local build. The source package just built cannot be installed, you need
   to build the artifacts instead. Use this command to build an unsigned set of
   packages in the parent directory:
   
   .. code-block:: bash
   
      debuild -us -uc --lintian-opts --no-lintiandebuild -us -uc --no-lintian

#. The new Debian source package cannot be installed, but it can be uploaded 
   to Launcpad where it will be built:
   
   .. code-block:: bash

      dput ppa:learningequality/ka-lite blahblah.changes

How to develop the debian/ sources
----------------------------------

This section is about developing the scripts that pertain installing, updating, configuring and system service for the Debian package of KA Lite: We can call these *maint* scripts, or just "Debian sources".

If you are changing these and need to test locally (because that's a lot faster), do the following to test everything WITHOUT a full KA Lite source -- having 400+ MB of data in the package makes it slow.

Therefore, this development workflow SIMULATES KA Lite itself, but retains all of the packaging code.

.. code-block:: bash

    ./make_test_pkg.sh 1.2.3  # <- notice the version string required
    cd test/ka-lite-test
    debuild -us -uc  # Builds unsigned installable .deb files with no content
    debuild --no-lintian -us -uc  # Skips the lintian checks if you want
    DEBCONF_DEBUG=developer sudo dpkg --debug=3773 -i ../ka-lite_1.2.3_all.deb  # Installs the test package with highest debug level
    sudo dpkg -i ../ka-lite_1.2.3_all.deb  # Installs the test package WITHOUT all the debugging stuff
    cd ../../  # Go back to previous directory
    ./copy_from_pkg.sh  # By default, this command copies from the default test folder


To create a test package in another directory:

.. code-block:: bash

    ./make_test_pkg.sh path/to/test 1.2.3

If you want to copy the debian sources from another test setup, do:

.. code-block:: bash

    ./copy_from_pkg.sh path/to/other/pkg


Regarding **coding style**, all the so-called "maint" scripts (preinst/postinst/prerm/postrm/config) are
running ``/bin/bash`` and have the ``set -e`` option on. The intention is to be DRY and
to have lots of comments because many choices reflect tough experiences.

Consider reading this blog post: http://www.davidpashley.com/articles/writing-robust-shell-scripts/


Debugging tips
______________

Use ``set -x`` in bash scripts to enable debugging, it's extremely helpful.

Everything should be compatible with ``set -e``. See: http://www.davidpashley.com/articles/writing-robust-shell-scripts/

Run ``debconf-show ka-lite`` to view the ``ka-lite`` package debconf settings.

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

