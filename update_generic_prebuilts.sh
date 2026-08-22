#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
shopt -s nullglob

KERNEL_VERSION="6.18"

case ${ARCH:-} in
        arm64) kernel_image=Image ;;
        x86_64) kernel_image=bzImage ;;
        *) echo "ARCH is undefined or unknown" >&2; exit 1 ;;
esac

test -d "${ANDROID_BUILD_TOP:-}" || { echo "ANDROID_BUILD_TOP is undefined or missing" >&2; exit 1; }

# Select modules from the new build and avoid duplicating GKI modules.
common_modules=(common_dist/*.ko)
virt_modules=()
for module in virt_dist/*.ko; do
        if [[ ! -f common_dist/${module##*/} ]]; then
                virt_modules+=("$module")
        fi
done
test -s "common_dist/${kernel_image}"
(( ${#common_modules[@]} && ${#virt_modules[@]} ))

PREBUILT_PATH="$ANDROID_BUILD_TOP/kernel/prebuilts"
GKI_MODULES_PATH="${PREBUILT_PATH}/${KERNEL_VERSION}/${ARCH}"
VIRT_MODULES_PATH="${PREBUILT_PATH}/common-modules/virtual-device/${KERNEL_VERSION}/${ARCH//_/-}"

mkdir -p "${GKI_MODULES_PATH}" "${VIRT_MODULES_PATH}"
# Do not retain modules from a different build or signing key.
rm -f -- "${GKI_MODULES_PATH}"/*.ko "${VIRT_MODULES_PATH}"/*.ko
cp "$@" -- "${common_modules[@]}" "${GKI_MODULES_PATH}/"
cp "$@" -- "${virt_modules[@]}" "${VIRT_MODULES_PATH}/"
cp "$@" -- "common_dist/${kernel_image}" "${GKI_MODULES_PATH}/kernel-${KERNEL_VERSION}"
for suffix in gz lz4; do
        if [[ -f common_dist/${kernel_image}.${suffix} ]]; then
                cp "$@" -- "common_dist/${kernel_image}.${suffix}" "${GKI_MODULES_PATH}/kernel-${KERNEL_VERSION}-${suffix}"
        fi
done
