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
      etc.nixos-qemu = {
        source = ./qemu/flake.nix;
        target = "nixos/qemu/flake.nix";
      };
      systemPackages = [
        pkgs.disko # used to format disk and copy boot/kernel/userland files into it
        pkgs.git # using to ease doing git based setups
      ];
    };
    nix.settings = {
      substituters = lib.mkForce [ ]; # here to put n1 cachix
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    services.openssh.enable = true; # we can use ssh instead of impi
    services.sshd.enable = true;
    users.users.n1 = {
      isNormalUser = true;
      home = "/home/n1";
      extraGroups = [
        "root"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/PGg+j/Y5gP/e7zyMCyK+f0YfImZgKZ3IUUWmkoGtT dzmitry@nullstudios.xyz"
      ];
    };
    systemd.services.nixos-install = {
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        iproute2
        curl
        jq
        git
      ];
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        set -eux
        set -o pipefail
        echo 42
        curl https://www.example.com/
      '';
    };

    # add ssh

    # boot.loader.grub.devices = [ config.disko.devices.disk.sda.device ];
    # disko.devices = {
    #   disk = {
    #     default = {
    #       device = "/dev/vda";
    #       type = "disk";
    #       content = {
    #         type = "gpt";
    #         partitions = {
    #           ESP = {
    #             type = "EF00";
    #             size = "500M";
    #             content = {
    #               type = "filesystem";
    #               format = "vfat";
    #               mountpoint = "/boot";
    #               mountOptions = [ "umask=0077" ];
    #             };
    #           };
    #           root = {
    #             size = "100%";
    #             content = {
    #               type = "filesystem";
    #               format = "ext4";
    #               mountpoint = "/";
    #             };
    #           };
    #         };
    #       };
    #     };
    #   };
    # };
  };
}

# plymouth
