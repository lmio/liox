#!/usr/bin/env bash
set -euo pipefail

if [ $(id -u) -ne 0 ]
then
	echo "Script must be run as root"
	exit 1
fi

IMAGE_SIZE_MB=16384
SWAP_SIZE_MB=4096
ARCH="amd64"
BUILD_DIR="./mnt"
DEBOOTSTRAP_CACHE_DIR="./.cache/debootstrap"
APT_CACHE_DIR="./.cache/apt"
BUILD_IMAGE="./liox.img"

if [ -d "${BUILD_DIR}" ]
then
	echo "Directory \`${BUILD_DIR}\` exists"
	exit 1
fi

if [ -f "${BUILD_IMAGE}" ]
then
 	read -p "Image \`${BUILD_IMAGE}\` already exists. Rebuild? [y/N] " prompt
 	if [[ "${prompt}" != "y" && "${prompt}" != "Y" ]]
 	then
 		echo "Aborting"
 		exit 1
 	fi
else
    echo "Creating new image"
    dd if=/dev/zero of="${BUILD_IMAGE}" bs=1M count="${IMAGE_SIZE_MB}" status=progress
fi

set -x
BLOCK_DEVICE=$(sudo losetup --show -f "${BUILD_IMAGE}")
SWAP_END=$((513+SWAP_SIZE_MB))
EFIPART="${BLOCK_DEVICE}p1"
SWAPPART="${BLOCK_DEVICE}p2"
ROOTPART="${BLOCK_DEVICE}p3"
parted -s "${BLOCK_DEVICE}" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 boot on set 1 esp on \
    mkpart primary linux-swap 513MiB "${SWAP_END}MiB" \
    mkpart primary ext4 "${SWAP_END}MiB" 100%
mkfs.fat -F32 "${EFIPART}"
mkswap "${SWAPPART}"
mkfs.ext4 "${ROOTPART}"
mkdir -p "${BUILD_DIR}"
mount "${ROOTPART}" "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/boot/efi"
mount "${EFIPART}" "${BUILD_DIR}/boot/efi"

mkdir -p "${DEBOOTSTRAP_CACHE_DIR}" "${APT_CACHE_DIR}"
debootstrap \
    --cache-dir=$(realpath "${DEBOOTSTRAP_CACHE_DIR}") \
    --arch "${ARCH}" \
    stable "${BUILD_DIR}" https://deb.debian.org/debian

mkdir -p "${BUILD_DIR}/var/cache/apt/archives"
mount -t tmpfs chroot_tmp "${BUILD_DIR}/tmp"
mount --make-rslave --rbind /proc "${BUILD_DIR}/proc"
mount --make-rslave --rbind /sys  "${BUILD_DIR}/sys"
mount --make-rslave --rbind /dev  "${BUILD_DIR}/dev"
# mount --make-rslave --rbind /run  "${BUILD_DIR}/run"
mount --bind "${APT_CACHE_DIR}" "${BUILD_DIR}/var/cache/apt/archives"

function cleanup_mounts()
{
    umount "${BUILD_DIR}/tmp"
    umount -l "${BUILD_DIR}/proc"
    umount -l "${BUILD_DIR}/sys"
    umount -l "${BUILD_DIR}/dev"
    # umount -l "${BUILD_DIR}/run"
    umount "${BUILD_DIR}/var/cache/apt/archives"
    umount "${BUILD_DIR}/boot/efi"
    umount "${BUILD_DIR}"
    losetup -d "${BLOCK_DEVICE}"
    rmdir "${BUILD_DIR}"
}
trap cleanup_mounts EXIT

cp ./chroot-script.sh "${BUILD_DIR}"
cp -r ./includes.chroot "${BUILD_DIR}"
cat << EOF > "${BUILD_DIR}/etc/apt/apt.conf.d/99cache"
Binary::apt::APT::Keep-Downloaded-Packages "true";
APT::Keep-Downloaded-Packages "true";
EOF
mkdir -p "${BUILD_DIR}/etc/apt/preferences.d"
cp ./apt-preferences/* "${BUILD_DIR}/etc/apt/preferences.d"
cp ./olimp-control*.deb "${BUILD_DIR}/tmp"
chroot "${BUILD_DIR}" /bin/bash -c \
	"/bin/env -i \
    BLOCK_DEVICE=${BLOCK_DEVICE} \
    EFIPART=${EFIPART} \
    SWAPPART=${SWAPPART} \
    ROOTPART=${ROOTPART} \
    /bin/bash /chroot-script.sh"
