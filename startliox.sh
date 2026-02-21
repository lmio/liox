qemu-system-x86_64 \
    -bios $(nix-build '<nixpkgs>' -A OVMF.fd)/FV/OVMF.fd \
    -m 4G -smp 2 -accel kvm \
    -drive file=./liox.img,format=raw
