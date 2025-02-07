
{
  # ideally we should use exactly same commits as initrd image (should we use iso?)
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko = {
      url =  "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, disko, nixpkgs }: {
    nixosConfigurations.default = nixpkgs.legacyPackages.x86_64-linux.nixos [
      ./configuration.nix
      ./shared.nix
      disko.nixosModules.disko
      {
        disko.devices = {
          disk = {
            main = {
              # When using disko-install, we will overwrite this value from the commandline
              device = "/dev/disk/by-id/some-disk-id";
              type = "disk";
              content = {
                type = "gpt";
                partitions = {
                  MBR = {
                    type = "EF02"; # for grub MBR
                    size = "1M";
                    priority = 1; # Needs to be first partition
                  };
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
      }
    ];
  };
}