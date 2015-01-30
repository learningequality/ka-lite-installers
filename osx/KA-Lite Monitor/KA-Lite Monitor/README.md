KA-Lite Monitor OS X App
========================

This is the KA-Lite status menu app with the source and (hopefully) PyRun in one package.


## TODO(cpauya)

1. Check for KALITE_DIR and KALITE_PYTHON environment variables and re-use those instead.
1. Prompt for location of database, language packs, contents and persist somewhere outside the .app like a `local_settings.py`?
1. Generate a `local_settings.py` if none is found.
1. Get values from the `local_settings.py` like the IP address and port and use these to launch in browser.