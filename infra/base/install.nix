# Run from iPXE. Used to install full system from iPXE RAM boot
{
  config,
  lib,
  specialArgs,
  options,
  modulesPath,
  pkgs,
  inputs,
  system,
  self,
}:
{
  config =
    let
      path = with pkgs; [
        curl
        inputs.disko.packages.${system}.disko
        inputs.disko.packages.${system}.disko-install
        iproute2
        jq
        nix
        nixos-install-tools
        nixos-install
        util-linux
      ];

      closureInfo = pkgs.closureInfo {
        rootPaths =
          path
          ++ [
            # self.nixosConfigurations.base.config.system.build.toplevel
            # pkgs.stdenv.drvPath # adds 600MB, so less downloads after
            pkgs.stdenv
            pkgs.nano
            pkgs.perlPackages.ConfigIniFiles
            pkgs.perlPackages.FileSlurp
            # (pkgs.closureInfo { rootPaths = [ ]; }).drvPath
          ]
          ++ builtins.map (i: i.outPath) (builtins.attrValues specialArgs.inputs);
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
      environment.loginShellInit = ''
        sudo systemctl start nixos-install
      '';
      environment.shellInit = ''
        sudo systemctl start nixos-install
      '';
      systemd.user.services.nixos-install = {
        wantedBy = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path = path;
        enable = true;
        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = "30s";
        };
        script = builtins.readFile ./nixos-install-script.sh;
      };
    };
}
