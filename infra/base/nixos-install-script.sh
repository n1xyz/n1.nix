sudo nixos-generate-config --root /tmp/config --no-filesystems --force
sudo cp /etc/nixos/qemu/flake.nix /tmp/config/etc/nixos/
sudo cp /etc/nixos/shared.nix /tmp/config/etc/nixos/
sudo disko-install --flake '/tmp/config/etc/nixos#default' --disk main /dev/vda
