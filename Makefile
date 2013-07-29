#!/usr/bin/make -f

binary.iso:
	lb build

.PHONY: clean
clean:
	lb clean
