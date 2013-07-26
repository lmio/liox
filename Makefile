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
	ln -st config/package-lists ../../stuff/liox.list

.PHONY: clean
clean:
	lb clean
