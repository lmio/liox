#!/usr/bin/env bash
set -xeuo pipefail

if [ -f /tmp/contest.env ]; then
    source /tmp/contest.env
fi

CTRL_KEY="${CTRL_KEY:-nonsecret}"
LIOADMIN_PWD="${LIOADMIN_PWD:-lioadmin}"
GRUB_PWD="${GRUB_PWD:-grub}"
HOSTNAME="${HOSTNAME:-lioxbox}"

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

apt -y install linux-image-amd64 firmware-linux grub-efi debconf-utils gpg

mkdir -p /etc/apt/sources.list.d/
cp ./apt-sources/* /etc/apt/sources.list.d/
mkdir -p /etc/apt/trusted.gpg.d/
gpg --dearmor -o /etc/apt/trusted.gpg.d/sublimehq-pub.gpg < /apt-keys/sublimehq-pub.asc
gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg < /apt-keys/microsoft.asc
apt -y update

echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
echo "keyboard-configuration keyboard-configuration/variant select English (US)" | debconf-set-selections

apt -y install \
    task-laptop firmware-iwlwifi apt-file apt-transport-https manpages systemd-resolved \
    plasma-desktop kwin-x11 sddm sddm-theme-breeze xserver-xorg xserver-xorg-video-all \
    dolphin konsole kwrite ark gwenview okular kcalc \
    libreoffice-calc libreoffice-impress libreoffice-kf6 libreoffice-plasma libreoffice-writer \
    firefox-esr wget curl dnsutils tsocks bridge-utils ntpsec iptables-persistent whois rfkill \
    joe gedit scite geany geany-plugins codeblocks codeblocks-contrib \
    kate emacs nano kdevelop neovim vim vim-gtk3 sublime-text code \
    zsh mc strace lsof tree screen iotop tmux htop kpartx units locate bash-completion \
    git make gcc g++ gdb gdb-doc ddd valgrind clang \
    python3 ruby \
    python3-requests \
    /packages/*.deb

cp -rf /chroot-overlay/* /

for P in $(ls /usr/share/liox-config/patches/*.patch); do
    patch -d/ -p0 < ${P}
done
echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub

mkdir -p /etc/olimp-control
echo -n "${CTRL_KEY}" > /etc/olimp-control/key
chown root:root /etc/olimp-control/key
chmod 400 /etc/olimp-control/key

USER_LIST=()
function make_user()
{
    local USERNAME="$1"
    local PASSWORD_HASH=$(echo "$2" | mkpasswd -s -m sha-512)
    USER_LIST+=("${USERNAME}")
    useradd -m -s /bin/bash -p "${PASSWORD_HASH}" "${USERNAME}"
}

make_user lioadmin "${LIOADMIN_PWD}"
usermod -a -G sudo lioadmin

if [[ -v D0_PWD ]]; then
    make_user d0 "${D0_PWD}"
fi
if [[ -v D1_PWD ]]; then
    make_user d1 "${D1_PWD}"
fi
if [[ -v D2_PWD ]]; then
    make_user d2 "${D2_PWD}"
fi
/usr/share/liox-config/install_vscode_ext.sh "${USER_LIST[@]}"

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
update-initramfs -u -k all
grub-install --removable --target=x86_64-efi "${BLOCK_DEVICE}"
update-grub
rm -rf /etc/apt/apt.conf.d/99cache /chroot-script.sh

systemctl enable systemd-networkd
systemctl enable systemd-resolved
