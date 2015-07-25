from __future__ import print_function
from __future__ import unicode_literals

import logging
import os
import sys

# create logger with 'spam_application'
logger = logging.getLogger('kalite_gtk')
logger.setLevel(logging.DEBUG)

# create file handler which logs even debug messages
fh = logging.FileHandler(
    os.path.expanduser(
        os.path.join('~', '.kalite', 'kalite_gtk.log')
    )
)

fh.setLevel(logging.DEBUG)
# create console handler with a higher log level
ch = logging.StreamHandler()

if '--debug' in sys.argv:
    ch.setLevel(logging.DEBUG)
else:
    ch.setLevel(logging.ERROR)

# create formatter and add it to the handlers
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
fh.setFormatter(formatter)
ch.setFormatter(formatter)
# add the handlers to the logger
logger.addHandler(fh)
logger.addHandler(ch)
