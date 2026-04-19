#!/usr/bin/env sh
set -xe
mount /dev/sda2 /mnt/disk
mount /dev/sda1 /mnt/disk/boot/efi
mount --make-rslave --rbind /proc /mnt/disk/proc
mount --make-rslave --rbind /dev /mnt/disk/dev
chroot /mnt/disk /bin/bash -c 'export PATH=$PATH:/sbin && grub-install --target=x86_64-efi --removable /dev/sda && update-grub'
poweroff
