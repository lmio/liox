#!/usr/bin/make -f

binary.hybrid.iso:
	lb build

.PHONY: clean
clean:
	lb clean
