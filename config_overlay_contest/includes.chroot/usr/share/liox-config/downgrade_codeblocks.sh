#!/bin/bash
set -e

apt-get install -y libgdk-pixbuf-xlib-2.0-0 libgdk-pixbuf2.0-0

mkdir -p /tmp/cbfix
pushd /tmp/cbfix
wget http://ftp.lt.debian.org/debian/pool/main/c/codeblocks/codeblocks_20.03-3_amd64.deb
wget http://ftp.lt.debian.org/debian/pool/main/c/codeblocks/codeblocks-common_20.03-3_all.deb
wget http://ftp.lt.debian.org/debian/pool/main/c/codeblocks/codeblocks-contrib_20.03-3_amd64.deb
wget http://ftp.lt.debian.org/debian/pool/main/c/codeblocks/libcodeblocks0_20.03-3_amd64.deb
wget http://ftp.lt.debian.org/debian/pool/main/t/tiff/libtiff5_4.2.0-1+deb11u5_amd64.deb
wget http://ftp.lt.debian.org/debian/pool/main/libw/libwebp/libwebp6_0.6.1-2.1+deb11u2_amd64.deb
wget http://ftp.lt.debian.org/debian/pool/main/w/wxwidgets3.0/libwxbase3.0-0v5_3.0.5.1+dfsg-2_amd64.deb
wget http://ftp.lt.debian.org/debian/pool/main/w/wxwidgets3.0/libwxgtk3.0-gtk3-0v5_3.0.5.1+dfsg-2_amd64.deb
wget http://ftp.lt.debian.org/debian/pool/main/c/codeblocks/libwxsmithlib0_20.03-3_amd64.deb
dpkg -i *.deb
popd
