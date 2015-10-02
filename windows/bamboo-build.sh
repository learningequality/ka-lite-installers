#!/bin/bash
# Follow the instructions from README.md
# A script that can be run by bamboo, to build the installer
# Last updated 10/1/2015 for KA Lite version 0.15
source kavenv/bin/activate

pushd ka-lite
pip install -r requirements_dev.txt

python bin/kalite manage unpack_assessment_zip ../khan_assessment.zip
python setup.py sdist --static
python bin/kalite manage syncdb --noinput
python bin/kalite manage migrate --noinput

npm install
node build.js
rm -fr node_modules

python bin/kalite manage collectstatic --noinput
python bin/kalite manage compileymltojson

pushd docs
make html

popd
rm secretkey.txt

popd
wine inno-compiler/ISCC.exe installer-source/KaliteSetupScript.iss