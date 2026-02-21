#!/usr/bin/env bash
set -xeuo pipefail

CTRL_KEY="abcde"
LIOADMIN_PWD="lioadmin"
GRUB_PWD="grub"
HOSTNAME="lioxbox"
TIMEZONE="Europe/Vilnius"

export LANG=C.UTF-8
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root
export SHELL=/bin/bash
export TERM=xterm
export DEBIAN_FRONTEND=noninteractive

apt -y install lsb-release
CODENAME=$(lsb_release --codename --short)
cat > /etc/apt/sources.list << EOF
deb https://deb.debian.org/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ ${CODENAME} main contrib non-free non-free-firmware

deb https://security.debian.org/debian-security ${CODENAME}-security main contrib non-free non-free-firmware
deb-src https://security.debian.org/debian-security ${CODENAME}-security main contrib non-free non-free-firmware

deb https://deb.debian.org/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
deb-src https://deb.debian.org/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
EOF

apt -y update

rm /etc/localtime
echo "${TIMEZONE}" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

apt -y install locales
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "lt_LT.UTF-8 UTF-8" >> /etc/locale.gen
echo "pl_PL.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=\"en_US.UTF-8\"" > /etc/default/locale
locale-gen

echo "${HOSTNAME}" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1 localhost
127.0.1.1 ${HOSTNAME}

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

apt -y install linux-image-amd64 firmware-linux grub-efi debconf-utils wget gpg

mkdir -p /etc/apt/trusted.gpg.d/
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/vscode.list
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/sublimehq-archive.gpg
wget -qO - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/ms-vscode-keyring.gpg
apt -y update

echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
echo "keyboard-configuration keyboard-configuration/variant select English (US)" | debconf-set-selections
echo "localepurge localepurge/nopurge multiselect en, en_US, en_US.UTF-8, lt, lt_LT, lt_LT.UTF-8, pl, pl_PL, pl_PL.UTF-8, ru, ru_RU, ru_RU.UTF-8" | debconf-set-selections
echo "localepurge localepurge/use-dpkg-feature boolean false" | debconf-set-selections

apt -y install \
    task-laptop \
    plasma-desktop kwin-x11 sddm sddm-theme-breeze xserver-xorg \
    dolphin konsole kwrite ark gwenview okular \
    firefox-esr wget \
    xserver-xorg-video-all \
    vim-gtk3 joe gedit scite geany geany-plugins codeblocks codeblocks-contrib \
    kate \
    zsh mc emacs nano git \
    make gcc g++ gdb ddd valgrind \
    python3 \
    strace lsof tree curl dnsutils screen \
    iotop tmux htop kpartx tsocks units locate \
    bridge-utils bash-completion rfkill apt-file ntpsec locales \
    iptables-persistent \
    localepurge \
    gdb-doc manpages \
    python3-requests \
    kcalc apt-transport-https \
    clang firmware-iwlwifi kdevelop \
    libreoffice-calc libreoffice-impress libreoffice-kf6 libreoffice-plasma libreoffice-writer \
    neovim ruby vim whois \
    sublime-text code \
    /tmp/olimp-control*.deb

cp -rf /includes.chroot/* /

for P in $(ls /usr/share/liox-config/patches/*.patch); do
    patch -d/ -p0 < ${P}
done
echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub

mkdir -p /etc/olimp-control
echo -n "${CTRL_KEY}" > /etc/olimp-control/key
chown root:root /etc/olimp-control/key
chmod 400 /etc/olimp-control/key

# useradd -m -s /bin/bash -p ${D0_PWD_HASH} d0
# useradd -m -s /bin/bash -p ${D1_PWD_HASH} d1
# useradd -m -s /bin/bash -p ${D2_PWD_HASH} d2
LIOADMIN_PWD_HASH=$(echo "${LIOADMIN_PWD}" | mkpasswd -s -m sha-512)
useradd -m -s /bin/bash -p "${LIOADMIN_PWD_HASH}" lioadmin
usermod -a -G sudo lioadmin

GRUB_PWD_HASH=$(printf "%s\n%s" "${GRUB_PWD}" "${GRUB_PWD}" | grub-mkpasswd-pbkdf2 | awk '/grub.pbkdf/{print$NF}')
mkdir -p /boot/grub
cat > /boot/grub/custom.cfg <<EOF
set superusers="lioadmin"
password_pbkdf2 lioadmin ${GRUB_PWD_HASH}
EOF

EFI_UUID=$(blkid -s UUID -o value "${EFIPART}")
SWAP_UUID=$(blkid -s UUID -o value "${SWAPPART}")
ROOT_UUID=$(blkid -s UUID -o value "${ROOTPART}")
cat << EOF > /etc/fstab
UUID=${EFI_UUID}    /boot/efi   vfat umask=0077                     0   1
UUID=${SWAP_UUID}   swap        swap defaults                       0   0
UUID=${ROOT_UUID}   /           ext4 defaults,errors=remount-ro     0   1
EOF
grub-install --removable --target=x86_64-efi "${BLOCK_DEVICE}"
update-grub
rm -rf /includes.chroot /etc/apt/apt.conf.d/99cache /chroot-script.sh

systemctl enable systemd-networkd
