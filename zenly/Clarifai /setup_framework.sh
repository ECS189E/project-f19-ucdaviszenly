#!/bin/sh
set -e

readonly CLARIFAI_DIRECTORY="${PROJECT_DIR}/Clarifai"

function strip_framework() {
    local originalFramework="${CLARIFAI_DIRECTORY}/Clarifai_Apple_SDK.framework.original"
    local platformFramework="${CLARIFAI_DIRECTORY}/Clarifai_Apple_SDK.framework"
    local activePlatformFile="${CLARIFAI_DIRECTORY}/ActivePlatform"
    local activePlatform=""
    declare -a architectures=()

    if [[ -a ${activePlatformFile} ]]; then
        activePlatform=$(cat ${activePlatformFile})
    fi

    if [[ ! -a ${originalFramework} ]]; then
        mv "${platformFramework}" "${originalFramework}"
    fi

    if [[ -a ${platformFramework} && -n ${activePlatform} && ${activePlatform} != ${PLATFORM_NAME} ]]; then
        rm -rf "${platformFramework}"
    fi

    if [[ ! -a ${platformFramework} ]]; then
        cp -r "${originalFramework}" "${platformFramework}"
    fi

    if [[ -z ${activePlatform} || ${activePlatform} != ${PLATFORM_NAME} ]]; then
        echo ${PLATFORM_NAME} > ${activePlatformFile}

        if [[ ${PLATFORM_NAME} == "iphoneos" ]]; then
            architectures=("x86_64")
        elif [[ ${PLATFORM_NAME} == "iphonesimulator" ]]; then
            architectures=("armv7" "arm64")
        fi

        local numberOfArchitectures=${#architectures[*]}
        local architecture=""

        for (( i = 0; i < ${numberOfArchitectures}; i++ )); do
            architecture=${architectures[$i]}
            lipo -remove ${architecture} "${platformFramework}/Clarifai_Apple_SDK" -output "${platformFramework}/Clarifai_Apple_SDK"
        done

        local frameworksDirectory="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
        local clarifaiAppleSDK="${frameworksDirectory}/Clarifai_Apple_SDK.framework"

        rm -rf "${clarifaiAppleSDK}"
        cp -r "${platformFramework}" "${clarifaiAppleSDK}"
    fi
}

strip_framework

exit 0
