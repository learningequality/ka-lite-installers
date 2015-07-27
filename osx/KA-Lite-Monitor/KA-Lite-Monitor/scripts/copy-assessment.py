#!/usr/bin/env python

import os
import sys
import shutil

KALITE_CONTENT = ''
ASSESSMENT = ''

if len(sys.argv) > 1:
    ASSESSMENT = sys.argv[1]
    if not os.path.exists(ASSESSMENT):
        print '==> ASSESSMENT "%s" is invalid!' % ASSESSMENT
        exit(1)
if len(sys.argv) > 2:
    KALITE_CONTENT = sys.argv[2]
    if not os.path.exists(KALITE_CONTENT):
        print '==> KALITE_CONTENT "%s" is invalid!' % KALITE_CONTENT
        exit(1)

KALITE_CONTENT = KALITE_CONTENT + "/content"

shutil.rmtree(KALITE_CONTENT)
shutil.copytree(ASSESSMENT, KALITE_CONTENT)