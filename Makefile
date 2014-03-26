#!/usr/bin/make -f

VSN = $(shell git describe --tags)

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
	kvm -no-reboot \
		-cdrom liox-$(VSN).iso \
		-kernel binary/install/vmlinuz \
		-initrd binary/install/initrd.gz \
		-append "vga=788 auto=true priority=critical keymap=us $(AUTO) $(DBG)" \
		liox-$(VSN).vdi
