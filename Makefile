#!/usr/bin/make -f

BASENAME ?= liox-$(shell git describe --tags)-$(LIOX_ARCH)$(LIOX_CONTEST)
QEMU ?= qemu-system-x86_64 -enable-kvm -cpu host

.PHONY: clean vm iso

iso: $(BASENAME).iso

$(BASENAME).iso:
	lb config
	mkdir -p config/includes.chroot/etc
	echo $(BASENAME) > config/includes.chroot/etc/liox_version
	lb build
	mv live-image-*.hybrid.iso $@

$(BASENAME).raw:
	qemu-img create -f raw $@ 7.45G

clean:
	lb clean

AUTO := preseed/file=/cdrom/preseed/auto.cfg
DBG := DEBCONF_DEBUG=5
vm: $(BASENAME).raw $(BASENAME).iso
	$(QEMU) -no-reboot -smp 2 \
		-m 256M \
		-monitor stdio \
		-display gtk \
		-cdrom $(BASENAME).iso \
		-drive file=$(BASENAME).raw,format=raw \
		-kernel binary/install/vmlinuz \
		-initrd binary/install/initrd.gz \
		-append "auto=true priority=critical keymap=us $(AUTO) $(DBG)"
