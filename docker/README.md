[![Build Status](https://travis-ci.org/lmio/liox?branch=master)](https://travis-ci.org/lmio/liox)

LMIO image in Docker
--------------------

This is an experimental attempt to build the liox image using the docker container.

When it succeeds, this README will be updated.

Benefits:
- no need to virtualize to make the image (just docker is enough).
- simpler setup: replace debian-live setup with debootstrap.
- continuous integration.
- much faster (clean build + test in 6 minutes on travis-ci).
