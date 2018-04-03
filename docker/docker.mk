.PHONY: img lint start

SCRIPTS = $(shell awk '/\#!\/bin\/bash/ && FNR == 1 {print FILENAME}' docker/*)

img: liox-$(VSN).img

lint:
	shellcheck $(SCRIPTS)

liox-$(VSN).img: .tmp/.faux_container
	docker run -ti --rm --privileged \
		--name liox_builder \
		--env IMG_DST=/x/$@ \
		--env KERNEL_DST=/x/vmlinuz-$(VSN) \
		--env INITRD_DST=/x/initrd.img-$(VSN) \
		-v `pwd`:/x \
		liox_builder /x/docker/create

start: liox-$(VSN).img
	docker/start $(VSN)
	@echo "See boot.log for boot status"
	@echo "Use \"ssh -p 5555 liox@localhost\" (passwd: liox) to reach it"

stop:
	kill $(shell cat qemu.pid)
	rm qemu.pid

test: liox-$(VSN).img
	docker run -ti --rm \
		--name liox_tester \
		-v `pwd`:/x \
		liox_builder \
		/x/docker/test /x/ $(VSN)

.tmp/.faux_container: docker/Dockerfile
	docker build -t liox_builder docker
	mkdir -p $(dir $@) && touch $@
