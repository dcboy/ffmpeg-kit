#!/bin/bash

# delete old build.log
rm -rf build.log

if [[ -z ${ANDROID_SDK_ROOT} ]]; then
  echo -e "\n(*) ANDROID_SDK_ROOT not defined\n"
  exit 1
fi

if [[ -z ${ANDROID_NDK_ROOT} ]]; then
  echo -e "\n(*) ANDROID_NDK_ROOT not defined\n"
  exit 1
fi

# LOAD INITIAL SETTINGS
export BASEDIR="$(pwd)"
export FFMPEG_KIT_BUILD_TYPE="android"
source "${BASEDIR}"/scripts/variable.sh
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh
disabled_libraries=()
mkdir -p "${BASEDIR}"/release

# SET DEFAULTS SETTINGS
enable_default_android_architectures
enable_default_android_libraries
enable_main_build

# DETECT ANDROID NDK VERSION
export DETECTED_NDK_VERSION=$(grep -Eo "Revision.*" "${ANDROID_NDK_ROOT}"/source.properties | sed 's/Revision//g;s/=//g;s/ //g')
echo -e "\nINFO: Using Android NDK v${DETECTED_NDK_VERSION} provided at ${ANDROID_NDK_ROOT}\n" 1>>"${BASEDIR}"/build.log 2>&1
echo -e "INFO: Build options: $*\n" 1>>"${BASEDIR}"/build.log 2>&1

# SET DEFAULT BUILD OPTIONS
# export GPL_ENABLED="no"
# DISPLAY_HELP=""
# BUILD_FULL=""
# BUILD_TYPE_ID=""
# BUILD_VERSION=$(git describe --tags --always 2>>"${BASEDIR}"/build.log)

# # PROCESS LTS BUILD OPTION FIRST AND SET BUILD TYPE: MAIN OR LTS
# rm -f "${BASEDIR}"/android/ffmpeg-kit-android-lib/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
# cp "${BASEDIR}"/tools/android/build.gradle "${BASEDIR}"/android/ffmpeg-kit-android-lib/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
# for argument in "$@"; do
#   if [[ "$argument" == "-l" ]] || [[ "$argument" == "--lts" ]]; then
#     enable_lts_build
#     BUILD_TYPE_ID+="LTS "
#     rm -f "${BASEDIR}"/android/ffmpeg-kit-android-lib/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
#     cp "${BASEDIR}"/tools/android/build.lts.gradle "${BASEDIR}"/android/ffmpeg-kit-android-lib/build.gradle 1>>"${BASEDIR}"/build.log 2>&1
#   fi
# done


  echo -n -e "\nffmpeg-kit: "

  # CREATE Application.mk FILE BEFORE STARTING THE NATIVE BUILD
  build_application_mk

  # CLEAR OLD NATIVE LIBRARIES
  rm -rf "${BASEDIR}"/android/libs 1>>"${BASEDIR}"/build.log 2>&1
  rm -rf "${BASEDIR}"/android/obj 1>>"${BASEDIR}"/build.log 2>&1

  cd "${BASEDIR}"/android 1>>"${BASEDIR}"/build.log 2>&1 || exit 1

  # BUILD NATIVE LIBRARY
  if [[ ${SKIP_ffmpeg_kit} -ne 1 ]]; then
    if [ "$(is_darwin_arm64)" == "1" ]; then
       arch -x86_64 "${ANDROID_NDK_ROOT}"/ndk-build -B 1>>"${BASEDIR}"/build.log 2>&1
    else
      "${ANDROID_NDK_ROOT}"/ndk-build -B 1>>"${BASEDIR}"/build.log 2>&1
    fi

    if [ $? -eq 0 ]; then
      echo "ok"
    else
      echo "failed"
      exit 1
    fi
  else
    echo "skipped"
  fi

  echo -e -n "\n"

  # DO NOT BUILD ANDROID ARCHIVE
  if [[ ${NO_ARCHIVE} -ne 1 ]]; then

    echo -e -n "\nCreating Android archive under prebuilt: "

    # BUILD ANDROID ARCHIVE
    rm -f "${BASEDIR}"/android/ffmpeg-kit-android-lib/build/outputs/aar/ffmpeg-kit-release.aar 1>>"${BASEDIR}"/build.log 2>&1
    ./gradlew ffmpeg-kit-android-lib:clean ffmpeg-kit-android-lib:assembleRelease ffmpeg-kit-android-lib:testReleaseUnitTest 1>>"${BASEDIR}"/build.log 2>&1
    if [ $? -ne 0 ]; then
      echo -e "failed\n"
      exit 1
    fi

    # COPY ANDROID ARCHIVE TO PREBUILT DIRECTORY
    FFMPEG_KIT_AAR="${BASEDIR}/prebuilt/$(get_aar_directory)/ffmpeg-kit"
    rm -rf "${FFMPEG_KIT_AAR}" 1>>"${BASEDIR}"/build.log 2>&1
    mkdir -p "${FFMPEG_KIT_AAR}" 1>>"${BASEDIR}"/build.log 2>&1
    cp "${BASEDIR}"/android/ffmpeg-kit-android-lib/build/outputs/aar/ffmpeg-kit-release.aar "${BASEDIR}"/release/ffmpeg-kit-"$(date +%Y%m%d%H%M%S)".aar 1>>"${BASEDIR}"/build.log 2>&1
    if [ $? -ne 0 ]; then
      echo -e "failed\n"
      exit 1
    fi

    echo -e "INFO: Created ffmpeg-kit Android archive successfully.\n" 1>>"${BASEDIR}"/build.log 2>&1
    echo -e "ok\n"
  else
    echo -e "INFO: Skipped creating Android archive.\n" 1>>"${BASEDIR}"/build.log 2>&1
  fi