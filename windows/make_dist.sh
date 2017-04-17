pushd ka-lite

/usr/local/bin/virtualenv venv
source venv/bin/activate
pip install -r requirements_dev.txt
pip install -r requirements_sphinx.txt
/usr/bin/make dist
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
deactivate
rm -r venv

popd