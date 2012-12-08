#!/bin/sh

#  build.sh
#  TDEventsFramework
#
#  Created by Gabriel Pacheco on 10/20/12.
#


LIB_TARGET_NAME="$1"
PUBLIC_BUILD_DIR="${PROJECT_DIR}/binary_${LIB_TARGET_NAME}/"
PUBLIC_HEADERS_DIR="${PUBLIC_BUILD_DIR}Include/"
# Check arg
if [ "${#LIB_TARGET_NAME}" == 0 ]
then
	echo "Aborting! no target name specified as first argument!"
	exit 2
fi



# Build action only
if [ "${ACTION}" = "build" ]
then
# Clean up
	echo "Cleaning old binary."
	rm -rf "${PUBLIC_BUILD_DIR}"
	rm -rf "${PROJECT_DIR}/build"
	cd "${PROJECT_DIR}"

# Buid in All iOS Archs including simulator
	echo "Building Libraries"
	for TARGET in ${SUPPORTED_PLATFORMS}; do
		echo "Build library for target: ${TARGET}"
		xcodebuild -target "$LIB_TARGET_NAME" -configuration ${CONFIGURATION} -sdk ${TARGET} RUN_CLANG_STATIC_ANALYZER=${RUN_CLANG_STATIC_ANALYZER}
		RETVAL=$?
		if [ $RETVAL -ne 0 ]
		then
			echo "Aborting! could not build library with target '${TARGET}'"
		exit 2
		fi
	done

# Generate universal Lib
	ARM_FILES="${PROJECT_DIR}/build/${CONFIGURATION}-iphoneos/lib${LIB_TARGET_NAME}.a"
	I386_FILES="${PROJECT_DIR}/build/${CONFIGURATION}-iphonesimulator/lib${LIB_TARGET_NAME}.a"
	if [ ! -f ${ARM_FILES} ]
	then
		rm -rf "${PROJECT_DIR}/build"
		echo "Aborting! ARM library does not exists in path ${ARM_FILES}"
		exit 2
	fi
	if [ ! -f ${I386_FILES} ]
	then
		rm -rf "${PROJECT_DIR}/build"
		echo "Aborting! i386 library does not exists in path ${I386_FILES}"
		exit 2
	fi
	mkdir -p "${PUBLIC_BUILD_DIR}"
	echo "Merging libraries..." 
	lipo -create "$ARM_FILES" "$I386_FILES" -o "${PUBLIC_BUILD_DIR}lib${LIB_TARGET_NAME}.a"

# Checking archs
	echo "Checking architectures"
	lipo "${PUBLIC_BUILD_DIR}lib${LIB_TARGET_NAME}.a" -verify_arch ${VALID_ARCHS}
	RETVAL=$?
	if [ $RETVAL -ne 0 ]
	then
		rm -rf "${PUBLIC_BUILD_DIR}"
		rm -rf "${PROJECT_DIR}/build"
		echo "Aborting! lib${LIB_TARGET_NAME}.a does NOT contains all valid archs (${VALID_ARCHS})"
		exit 2
	else
		echo "lib${LIB_TARGET_NAME}.a passed in lipo test to validate archs (${VALID_ARCHS})"
	fi

# Copy Public Headers
	mkdir -p "${PUBLIC_HEADERS_DIR}"
	echo "Copying 'include' resources..."
	ARM_HEADERS="${PROJECT_DIR}/build/${CONFIGURATION}-iphoneos/usr/local/include/"
	cp -R -v "${ARM_HEADERS}" "${PUBLIC_HEADERS_DIR}"

# Clean
	echo "Removing tmp libraries..."
	rm -rf "${PROJECT_DIR}/build"

fi