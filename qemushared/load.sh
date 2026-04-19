#!/usr/bin/env sh
mkdir -p /mnt/disk
set -xe
apk add e2fsprogs dosfstools parted zstd lsblk blkid mount tar

parted -s /dev/sda \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 boot on \
    set 1 esp on \
    mkpart primary ext4 513MiB 100%

yes | mkfs.fat -F32 /dev/sda1
yes | mkfs.ext4 /dev/sda2

mount /dev/sda2 /mnt/disk
tar --numeric-owner -xpf /mnt/rootfs/rootfs.tar.zstd -C /mnt/disk
mkdir -p /mnt/disk/boot/efi
mount /dev/sda1 /mnt/disk/boot/efi

EFI_UUID=$(blkid -s UUID -o value /dev/sda1)
ROOT_UUID=$(blkid -s UUID -o value /dev/sda2)
cat << EOF > /mnt/disk/etc/fstab
UUID=${EFI_UUID}    /boot/efi   vfat umask=0077                     0   1
UUID=${ROOT_UUID}   /           ext4 defaults,errors=remount-ro     0   1
EOF

mount --make-rslave --rbind /proc /mnt/disk/proc
mount --make-rslave --rbind /dev /mnt/disk/dev
chroot /mnt/disk /bin/bash -c 'export PATH=$PATH:/sbin && grub-install --target=x86_64-efi --removable /dev/sda && update-grub'
poweroff
