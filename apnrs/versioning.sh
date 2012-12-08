#!/bin/sh

#  versioning.sh
#  TDEventsFramework
#
#  Created by Gabriel Pacheco on 4/18/12.
#  Copyright (c) 2012 TotenDev. All rights reserved.

# Get args
UPDATE_FILE_NAME="${1}"
UPDATE_DEFINE_STRING="${2}"

# Check args
if [ "${#UPDATE_FILE_NAME}" == 0 ]
then
	echo "Aborting! no file name specified as first argument!"
	exit 2
fi
if [ "${#UPDATE_DEFINE_STRING}" == 0 ]
then
	echo "Aborting! no #DEFINE string name specified as second argument!"
	exit 2
fi

# Build action only
if [ "${ACTION}" = "build" ]
then
	echo "Updating build version."
	cd ${PROJECT_DIR}/${PROJECT}
	# Get old version
	oldVersion=$(cat "${UPDATE_FILE_NAME}" | grep "${UPDATE_DEFINE_STRING}")
	oldVersionFloat=$(echo ${oldVersion} | sed "s/#define ${UPDATE_DEFINE_STRING} @\"//")
	oldVersionFloat=$(echo ${oldVersionFloat} | sed "s/\"//")
	# Update float version
	newVersion=$(echo "${oldVersionFloat}+0.0001" | bc )
	newVersion=$( printf "%1.4f" ${newVersion} )
	# Write
	echo "Writing into file and cleaning tmp"
	sed "s/${UPDATE_DEFINE_STRING} @\"[0-9].*\"/${UPDATE_DEFINE_STRING} @\"${newVersion}\"/g"  "${UPDATE_FILE_NAME}" > "/tmp/tmp.versioning"
	cat "/tmp/tmp.versioning" > "${UPDATE_FILE_NAME}"
	rm -rf "/tmp/tmp.versioning"
fi