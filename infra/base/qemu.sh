qemu-system-x86_64 -enable-kvm -drive "file=ssd.qcow2,if=virtio,discard=on,cache=none" -m 8192 -nographic\
  -kernel result/bzImage   -initrd result/initrd\
  -append "console=ttyS0 root=/dev/ram0 rw init=/nix/store/1x107z92rh680ldy41d11nqicyqvwc9v-nixos-system-nixos-24.11.20241231.edf04b7/init  initrd=initrd nohibernate loglevel=4"
