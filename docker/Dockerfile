FROM debian:stretch

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install \
      -y --no-install-recommends \
      parted debootstrap udev bc openssh-client qemu-system-x86 make

RUN ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
