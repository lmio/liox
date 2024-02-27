#!/bin/sh
set -x
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t tmpfs tmp /run
mkdir -p /run/systemd
mount / -o remount,rw
sed -i 's/ *init=[/\.a-zA-Z_-]*//' /etc/default/grub
/usr/sbin/update-grub

ROOT_PART_DEV=$(findmnt / -o source -n)
ROOT_PART_NAME=$(echo "$ROOT_PART_DEV" | cut -d "/" -f 3)
ROOT_DEV_NAME=$(echo /sys/block/*/"${ROOT_PART_NAME}" | cut -d "/" -f 4)
ROOT_DEV="/dev/${ROOT_DEV_NAME}"
ROOT_PART_NUM=$(cat "/sys/block/${ROOT_DEV_NAME}/${ROOT_PART_NAME}/partition")
ROOT_DEV_SIZE=$(cat "/sys/block/${ROOT_DEV_NAME}/size")
TARGET_END=$((ROOT_DEV_SIZE - 1))

printf "fix\n" | parted ---pretend-input-tty "$ROOT_DEV" print
if ! yes | parted ---pretend-input-tty -m -a opt $ROOT_DEV "resizepart $ROOT_PART_NUM 100%"; then
	echo "Failed resizing root filesystem"
	sleep infinity
else
	resize2fs ${ROOT_DEV}${ROOT_PART_NUM}
	sync
	mount / -o remount,ro
	whiptail --infobox "Resized root filesystem, rebooting..." 20 60
	sleep 5
fi

reboot -f
