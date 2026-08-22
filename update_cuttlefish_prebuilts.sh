#!/usr/bin/env bash

#set -e

KERNEL_VERSION="6.18"

# device/google/cuttlefish/shared/BoardConfig.mk
kernel_image_src=
if [[ "${ARCH}" == "arm64" ]]; then
        kernel_image_src="Image"
elif [[ "${ARCH}" == "x86_64" ]]; then
        kernel_image_src="bzImage"
else
        echo "ARCH is undefined or unknown"
        exit 1
fi

test -d "$ANDROID_BUILD_TOP" || (echo "ANDROID_BUILD_TOP is undefined or missing" && exit 1)

PREBUILT_PATH="$ANDROID_BUILD_TOP/kernel/prebuilts"
GKI_MODULES_PATH="${PREBUILT_PATH}/${KERNEL_VERSION}/${ARCH}"
VIRT_MODULES_PATH="${PREBUILT_PATH}/common-modules/virtual-device/${KERNEL_VERSION}/${ARCH//_/-}"

for file in $(find ${GKI_MODULES_PATH} -maxdepth 1 -type f -printf "%f\n"); do
        cp "$@" common_dist/$file ${GKI_MODULES_PATH}/$file > /dev/null 2>&1
done
cp "$@" common_dist/${kernel_image_src} ${GKI_MODULES_PATH}/kernel-${KERNEL_VERSION}

# keep in sync
for suffix in gz lz4; do
        cp "$@" common_dist/${kernel_image_src}.${suffix} \
        ${GKI_MODULES_PATH}/kernel-${KERNEL_VERSION}-${suffix} > /dev/null 2>&1
done

for file in $(find ${VIRT_MODULES_PATH} -maxdepth 1 -type f -printf "%f\n"); do
        cp "$@" virt_dist/$file ${VIRT_MODULES_PATH}/$file
done
