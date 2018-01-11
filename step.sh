#!/bin/bash

# fail if any commands fails
#set -e
# TODO: fix CMD exits with error "Build: command not found" even though the file is created

# debug log
#set -x

CMD="xcodebuild"

if [ -n "${xcode_project_path}" ] ; then
    CMD+=" -project ${xcode_project_path}"
else
    echo "Error: xcode_project_path not set"
    exit 1
fi
if [ -n "${xcode_scheme}" ] ; then
    CMD+=" -scheme \"${xcode_scheme}\""
else
    echo "Error: xcode_scheme not set"
    exit 1
fi
if [ -n "${xcode_configuration}" ] ; then
    CMD+=" -configuration ${xcode_configuration}"
else
    echo "Error: xcode_configuration not set"
    exit 1
fi
if [ -n "${xcode_sdk}" ] ; then
    CMD+=" -sdk ${xcode_sdk}"
else
    echo "Error: xcode_sdk not set"
    exit 1
fi

if [ -n "${other_swift_flags}" ] ; then
    CMD+=" OTHER_SWIFT_FLAGS=\"${other_swift_flags}\""
fi

IOSSIM_OUT_DIR=`pwd`/build
CMD+=" SYMROOT=${IOSSIM_OUT_DIR}"

#CMD+=" -verbose"

CMD+=" build"

echo ${CMD}

# build the simulator
eval $CMD

# find the app

IOSSIM_APP_PATH=`find ${IOSSIM_OUT_DIR} -name "*.app"`

test -e ${OSSIM_APP_PATH} && echo ${OSSIM_APP_PATH}

IOSSIM_APP_DIR=`dirname ${IOSSIM_APP_PATH}`
IOSSIM_APP_FILE=`basename ${IOSSIM_APP_PATH}`

# strip scheme name from whitespaces
STRIPPED_SCHEME="$(echo -e "${xcode_scheme}" | tr -d '[:space:]')"

# compress the app directory
IOSSIM_ZIP_FILE="${STRIPPED_SCHEME}-${xcode_configuration}.zip"
pushd ${IOSSIM_APP_DIR}
zip -r -q ${IOSSIM_ZIP_FILE} ${IOSSIM_APP_FILE}
IOSSIM_ZIP_PATH=`pwd`/${IOSSIM_ZIP_FILE}
popd

test -e ${IOSSIM_ZIP_PATH} || exit 1

if [ -d "${deploy_dir}" ]; then
	cp -v ${IOSSIM_ZIP_PATH} ${deploy_dir}/
fi

if which envman >/dev/null; then
    envman add --key IOSSIM_ZIP_PATH --value ${IOSSIM_ZIP_PATH}
fi

exit 0
