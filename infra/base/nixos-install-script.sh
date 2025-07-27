nixos-generate-config --root /tmp/config --no-filesystems --force
cp /etc/nixos/qemu/flake.nix /tmp/config/etc/nixos/
cp /etc/nixos/shared.nix /tmp/config/etc/nixos/
disko-install --flake '/tmp/config/etc/nixos#default' --disk main /dev/vda
