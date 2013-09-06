#!/usr/bin/make -f

VSN = $(shell git describe --always)

binary-$(VSN).iso:
	lb build
	mv binary.iso $@

hdd-$(VSN).vdi:
	qemu-img create -f vdi $@ 10G

.PHONY: clean vm
clean:
	lb clean

AUTO := preseed/file=/cdrom/preseed/auto.cfg
DBG := DEBCONF_DEBUG=5
vm: hdd-$(VSN).vdi binary-$(VSN).iso
	kvm -no-reboot \
		-cdrom binary-$(VSN).iso \
		-kernel binary/install/vmlinuz \
		-initrd binary/install/initrd.gz \
		-append "vga=788 auto=true priority=critical keymap=us $(AUTO) $(DBG)" \
		hdd-$(VSN).vdi
