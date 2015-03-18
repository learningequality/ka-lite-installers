#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import
from __future__ import unicode_literals
import os
import sys

sys.path.append('ka-lite')

import kalite

from setuptools import setup, find_packages

requirements = [
    "Python>=2.7",
]

#############################
# DATA FILES
#############################
# To read more about this, please refer to:
# https://pythonhosted.org/setuptools/setuptools.html#including-data-files
#
# The bundled python-packages are considered data-files because they are
# platform independent and because they are not supposed to live in the general
# site-packages directory.


setup(
    name="kalite",
    version=kalite.VERSION,
    author="Foundation for Learning Equality",
    author_email="benjamin@learningequality.org",
    url="http://www.learningequality.org",
    description="KA Lite is a light-weight web server for viewing and interacting with core Khan Academy content (videos and exercises) without needing an Internet connection.",
    license="GPLv3",
    keywords="khan academy offline",
    packages=list(find_packages('./ka-lite')),
    zip_safe=False,
    install_requires=requirements,
    classifiers=[
        'Development Status :: 4 - Beta',
        'License :: OSI Approved :: GNU General Public License v3 (GPLv3)',
        'Environment :: Web Environment',
        'Framework :: Django',
        'Intended Audience :: Developers',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Topic :: Internet :: WWW/HTTP :: Dynamic Content',
        'Topic :: Software Development',
        'Topic :: Software Development :: Libraries :: Application Frameworks',
    ],
    include_package_data=True,
    test_suite='runtests',
)
