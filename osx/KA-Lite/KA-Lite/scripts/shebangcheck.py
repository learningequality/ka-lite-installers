#!/usr/bin/env python

# Accepts an argument as BIN_PATH that points to the python/pyrun interpreter to use.
# If not given, use the value of the KALITE_PYTHON environment variable.

import os
import sys
import subprocess

BIN_PATH = ""
if len(sys.argv) > 1:
    BIN_PATH = sys.argv[1]
    if not os.path.exists(BIN_PATH):
        print '==> BIN_PATH "%s" is invalid!' % BIN_PATH
        exit(1)

PYRUN = "pyrun"

# MUST: If no BIN_PATH, check if KALITE_PYTHON env var is set and use that instead.
if not BIN_PATH and "KALITE_PYTHON" in os.environ:
    # check if pyrun
    e = os.environ["KALITE_PYTHON"]
    if e[-5:] == PYRUN:
        BIN_PATH = e[:-5]

# Validate BIN_PATH
if not os.path.exists(BIN_PATH):
    print "==> The BIN_PATH '%s' is invalid!" % BIN_PATH
    exit(1)

PYRUN_PATH = os.path.join(BIN_PATH, 'pyrun')
KALITE_BIN_PATH = os.path.join(BIN_PATH, 'kalite')

SHEBANG_CHARS = "#!"
SHEBANG = SHEBANG_CHARS + PYRUN_PATH + os.linesep

# REF: http://stackoverflow.com/a/21655930/845481
# Replace first line of a file using sed command in a python script [closed]

# Loop thru all files on the folder
print 'Checking shebang of "%s" at %s' % (PYRUN_PATH, BIN_PATH,)
for root, dirs, files in os.walk(BIN_PATH):
    for filename in files:
        filename = os.path.join(BIN_PATH, filename)
        print '==> Checking shebang of %s' % filename
        try:
            with open(filename,'r+') as f:
                lines = f.readlines()
                if len(lines) < 1:
                    print '==> File has no content?'
                else:
                    r = lines[0]
                    # MUST: check that first two characters are the shebang chars
                    chars = r[:2]
                    if chars != SHEBANG_CHARS:
                        print '====> not SHEBANG_CHARS'
                    else:
                        if SHEBANG != r:
                            print '====> CHANGE %s to %s' % (r, SHEBANG,)
                            lines[0] = SHEBANG
                        else:
                            print "====> DON'T TOUCH!"
                        f.seek(0)
                        f.writelines(lines)
                        # MUST: Truncate if the string to replace is longer than the replacement.
                        f.truncate()
        except Exception as exc:
            print "==> EXCEPTION: %s" % exc
            exit(1)

print("Done!")