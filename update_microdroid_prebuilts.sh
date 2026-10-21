#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

KERNEL_VERSION="6.18"

case ${ARCH:-} in
    arm64) kernel_image=Image ;;
    x86_64) kernel_image=bzImage ;;
    *) echo "ARCH is undefined or unknown" >&2; exit 1 ;;
esac

test -d "${ANDROID_BUILD_TOP:-}" || { echo "ANDROID_BUILD_TOP is undefined or missing" >&2; exit 1; }
test -s "microdroid_dist/${kernel_image}"
test -s microdroid_dist/System.map

PREBUILT_PATH="$ANDROID_BUILD_TOP/packages/modules/Virtualization/guest/kernel/android17-${KERNEL_VERSION}/${ARCH}"
mkdir -p "${PREBUILT_PATH}"
cp "$@" -- "microdroid_dist/${kernel_image}" "${PREBUILT_PATH}/kernel-${KERNEL_VERSION}"
cp "$@" -- microdroid_dist/System.map "${PREBUILT_PATH}/System.map"
