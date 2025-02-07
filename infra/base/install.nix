# config used to install full system from iPXE RAM boot
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
        pkgs.curl
        pkgs.disko
        pkgs.git
        pkgs.nano
        pkgs.nix
        pkgs.nixos-install-tools
        pkgs.util-linux
      ];
    };
    systemd.services.nixos-install = {
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        curl
        disko
        iproute2
        jq
        nix
        nixos-install-tools
        util-linux
      ];
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "30s";
      };
      script = ''
        whoami
        # just to ensure that machine can download files and clone git repos if as needed, and have general access to inet
        curl https://status.backblaze.com/ | head -n 20
        curl https://www.githubstatus.com/api/v2/status.json | head -n 20
        nixos-generate-config --root /tmp/config --no-filesystems --force
        cp /etc/nixos/qemu/flake.nix /tmp/config/etc/nixos/
        cp /etc/nixos/shared.nix /tmp/config/etc/nixos/
        disko-install --flake '/tmp/config/etc/nixos#default' --disk main /dev/vda
      '';
    };
  };
}
