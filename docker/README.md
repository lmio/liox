[![Build Status](https://travis-ci.org/lmio/liox?branch=master)](https://travis-ci.org/lmio/liox)

LMIO image in Docker
--------------------

This is an experimental attempt to build the liox image using the docker container.

When it succeeds, this README will be updated.

Benefits:
- no need to virtualize to make the image (just docker is enough).
- simpler setup: replace debian-live setup with debootstrap.
- continuous integration.
- much faster.

Resize partition:
https://unix.stackexchange.com/questions/373063/auto-expand-last-partition-to-use-all-unallocated-space-using-parted-in-batch-m

Try `parted resizepart 1 100% Yes`

https://github.com/EugenMayer/parted-auto-resize/blob/master/resize.sh
