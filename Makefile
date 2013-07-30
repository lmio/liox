#!/usr/bin/make -f

binary.iso:
	lb build

hdd.vdi:
	qemu-img create -f vdi $@ 10G

.PHONY: clean vm
clean:
	lb clean

AUTO := preseed/file=/cdrom/preseed/auto.cfg
DBG := DEBCONF_DEBUG=5
vm: hdd.vdi binary.iso
	kvm -no-reboot \
		-cdrom binary.iso \
		-kernel binary/install/vmlinuz \
		-initrd binary/install/initrd.gz \
		-append "vga=788 auto=true priority=critical keymap=us $(AUTO) $(DBG)" \
		hdd.vdi
