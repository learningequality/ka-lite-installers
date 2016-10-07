#!/bin/bash

if [ ! -f debian/en.zip ]
then
    wget https://learningequality.org/downloads/ka-lite/0.17/content/contentpacks/en.zip -O debian/en.zip --no-clobber
else
    echo "en.zip is already here"
fi

output_dir=debian/ka-lite-bundle/usr/share/kalite/preseed/

if [ -d $output_dir ]
then
    echo "Content zip already in place, skipping"
else
    mkdir -p $output_dir
    cp debian/en.zip "$output_dir/contentpack-0.17.en.zip"
fi

