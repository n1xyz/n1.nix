{
  config,
  lib,
  specialArgs,
  options,
  modulesPath,
  pkgs,
}:
{
  config = {
    environment.systemPackages = [
      pkgs.disko # used to format disk and copy boot/kernel/userland files into it
      pkgs.git # using to ease doing git based setups
    ];
    boot.loader.grub.devices = [ config.disko.devices.disk.sda.device ];
    disko.devices = {
      disk = {
        default = {
          device = "/dev/vda";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "500M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}

# plymouth
