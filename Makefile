
binary.hybrid.iso: config
	lb build

config: stuff/splash.png
	lb config \
		--architecture i386 \
		--distribution wheezy \
		--debian-installer live \
		--bootloader grub \
		--grub-splash $(CURDIR)/stuff/splash.png \
		--archive-areas "main contrib non-free" \
		--parent-mirror-bootstrap http://ftp.lt.debian.org/debian
	ln -st config/package-lists ../../stuff/liox.list

.PHONY: clean
clean:
	lb clean
