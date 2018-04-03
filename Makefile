#!/usr/bin/make -f

VSN ?= $(shell git describe --tags)
QEMU ?= kvm

#DISPLAY = vga=788 # for nice graphics
DISPLAY = console=tty0 console=ttyS0,38400n8  # serial console

.PHONY: clean vm iso

iso: liox-$(VSN).iso

liox-$(VSN).iso:
	echo liox-$(VSN) > config/includes.chroot/etc/liox_version
	lb build
	mv binary.iso $@

liox-$(VSN).vdi:
	qemu-img create -f vdi $@ 10G

clean:
	lb clean

AUTO := preseed/file=/cdrom/preseed/auto.cfg
DBG := DEBCONF_DEBUG=5
vm: liox-$(VSN).vdi liox-$(VSN).iso
	$(QEMU) -no-reboot -smp 2 \
		-nographic \
		-cdrom liox-$(VSN).iso \
		-kernel binary/install/vmlinuz \
		-initrd binary/install/initrd.gz \
		-append "$(DISPLAY) auto=true priority=critical keymap=us $(AUTO) $(DBG)" \
		liox-$(VSN).vdi

include docker/docker.mk
