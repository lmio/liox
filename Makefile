#!/usr/bin/make -f

binary.hybrid.iso: config
	lb build

config:
	lb config \
		--architecture i386 \
		--distribution wheezy \
		--debian-installer live \
		--bootloader grub \
		--archive-areas "main contrib non-free" \
		--parent-mirror-bootstrap http://ftp.lt.debian.org/debian
	mkdir -p config/includes.chroot/usr/share/images/desktop-base
	mkdir -p config/includes.chroot/etc/vim
	ln -st config/package-lists ../../stuff/liox.list
	ln -st config/includes.chroot/etc/vim ../../../../stuff/vimrc.local
	ln -st config/includes.chroot/usr/share/images/desktop-base \
		../../../../../../stuff/lmio_logo.jpg
	ln -st config/hooks ../../stuff/wallpaper.chroot

.PHONY: clean
clean:
	lb clean
