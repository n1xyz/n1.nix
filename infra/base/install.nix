# Run from iPXE. Used to install full system from iPXE RAM boot
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
    let
      path = with pkgs; [
        curl
        disko
        iproute2
        jq
        nix
        nixos-install-tools
        nixos-install
        util-linux
      ];
      dependencies = [
        # config.system.build.toplevel
        # config.system.build.diskoScript
        # config.system.build.diskoScript.drvPath
        # pkgs.stdenv.drvPath

        # # https://github.com/NixOS/nixpkgs/blob/f2fd33a198a58c4f3d53213f01432e4d88474956/nixos/modules/system/activation/top-level.nix#L342
        # pkgs.perlPackages.ConfigIniFiles
        # pkgs.perlPackages.FileSlurp

        # (pkgs.closureInfo { rootPaths = [ ]; }).drvPath
      ]; # ++ builtins.map (i: i.outPath) (builtins.attrValues self.inputs);

      closureInfo = pkgs.closureInfo {
        rootPaths = path ++ [
          pkgs.nano
          pkgs.perlPackages.ConfigIniFiles
          pkgs.perlPackages.FileSlurp
          pkgs.stdenv
          # config.system.build.toplevel
            # (self.nixosConfigurations.base.pkgs.closureInfo { rootPaths = [ ]; }).drvPath
        ];
      };

    in
    {
      environment = {

        etc = {
          "install-closure".source = "${closureInfo}/store-paths";
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

      systemd.services.nixos-install = {
        wantedBy = [ "multi-user.target" ];
        path = path;
        serviceConfig = {
          Type = "simple";
          Restart = "no";
          RestartSec = "30s";
        };
        script = ''
          nixos-generate-config --root /tmp/config --no-filesystems --force
          cp /etc/nixos/qemu/flake.nix /tmp/config/etc/nixos/
          cp /etc/nixos/shared.nix /tmp/config/etc/nixos/          
          set +e
          # https://discourse.nixos.org/t/nixos-install-mount-command-not-found/59197
          disko-install --flake '/tmp/config/etc/nixos#default' --disk main /dev/vda
          set -e
        '';
      };
    };
}
