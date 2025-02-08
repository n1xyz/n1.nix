{
  # ideally we should use exactly same commits as initrd image (should we use iso?)
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      disko,
      nixpkgs,
    }:
    {
      nixosConfigurations.default = nixpkgs.legacyPackages.x86_64-linux.nixos [
        ./configuration.nix
        ./shared.nix
        # "${modulesPath}/modules/profiles/qemu-guest.nix"
        disko.nixosModules.disko
        {
          disko.devices = {
            disk = {
              main = {
                device = "/dev/vda";
                type = "disk";
                content = {
                  type = "gpt";
                  partitions = {
                    boot = {
                      size = "1M";
                      type = "EF02";
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
        {
          services = {
            getty.autologinUser = "n1";
          };
          boot.loader.timeout = 1;
          boot.loader.grub = {
            enable = true;
            default = "0";
            splashImage = null;
          };
        }
      ];
    };
}
