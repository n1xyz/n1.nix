/* Run from iPXE. Used to install full system from iPXE RAM boot */
{
  config,
  lib,
  specialArgs,
  options,
  modulesPath,
  pkgs,
}:
{
  config =
  let path = with pkgs; [
        curl
        disko
        iproute2
        jq
        nix
        nixos-install-tools
        util-linux
      ];
      in
   {
    environment = {
      etc = {
        nixos-qemu = {
          source = ./qemu/flake.nix;
          target = "nixos/qemu/flake.nix";
        };
        nixos-shared = {
          source = ./shared.nix;
          target = "nixos/shared.nix";
        };
      };
      systemPackages = [
        
      ] ++ path;
    };

    boot.loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/vda";
    };
    
    systemd.services.nixos-install = {
      wantedBy = [ "multi-user.target" ];
      path = path;
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "30s";
      };
      script = ''
        nixos-generate-config --root /tmp/config --no-filesystems --force
        cp /etc/nixos/qemu/flake.nix /tmp/config/etc/nixos/
        cp /etc/nixos/shared.nix /tmp/config/etc/nixos/
        disko-install --flake '/tmp/config/etc/nixos#default' --disk main /dev/vda
      '';
    };
  };
}
