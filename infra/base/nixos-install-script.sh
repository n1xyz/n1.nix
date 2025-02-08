sleep 10
nixos-generate-config --root /tmp/config --no-filesystems --force
cp /etc/nixos/qemu/flake.nix /tmp/config/etc/nixos/
cp /etc/nixos/shared.nix /tmp/config/etc/nixos/
set +e
# https://discourse.nixos.org/t/nixos-install-mount-command-not-found/59197
disko-install --flake '/tmp/config/etc/nixos#default' --disk main /dev/vda
set -e
echo "https://discourse.nixos.org/t/nixos-install-mount-command-not-found/59197"