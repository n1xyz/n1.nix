# extracts proper initrd folder
nix build .#base 
cat result/netboot.ipxe  | head -n 4 | tail -n 1 | sed -E 's@.*init=/nix/store/([^/]+)/init.*@\1@'
