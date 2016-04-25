#!/bin/bash

if [ ! -f debian/assessment.zip ]
then
	wget https://learningequality.org/downloads/ka-lite/0.16/content/khan_assessment.zip -O debian/assessment.zip --no-clobber
else
	echo "Assessment.zip is already here"
fi

output_dir=debian/ka-lite-bundle/usr/share/kalite/assessment/khan

if [ -d $output_dir ]
then
	echo "Assessment items already in place, skipping"
else
	mkdir -p $output_dir
        cd $output_dir
        umask 022
        cd -
	unzip debian/assessment.zip -d $output_dir
        chmod -R ugo+r $output_dir
fi
