{
  description = "Various solc and lsh versions";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko = {
      url = "github:nix-community/disko/v1.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      self,
      disko,
      ...
    }:
    let
      packagesFor = pkgs: rec {
        solc-0_8_26 = pkgs.callPackage ./solc-0.8.26.nix { };
        lsh = pkgs.callPackage ./lsh.nix { };
        agave-platform-tools = pkgs.callPackage ./agave-platform-tools.nix { };
        agave-cli = pkgs.callPackage ./agave-cli.nix {
          inherit agave-platform-tools;
        };
        base =
          let
            config = self.nixosConfigurations.base.config.system.build;
            kernelTarget = pkgs.stdenv.hostPlatform.linux-kernel.target;
          in
          pkgs.symlinkJoin {
            name = "base";
            paths = [
              config.netbootRamdisk
              config.kernel
              config.netbootIpxeScript
            ];
            postBuild = ''
              mkdir -p $out/nix-support
              echo "file ${kernelTarget} ${config.kernel}/${kernelTarget}" >> $out/nix-support/build-products
              echo "file initrd ${config.netbootRamdisk}/initrd" >> $out/nix-support/build-products
              echo "file ipxe ${config.netbootIpxeScript}/netboot.ipxe" >> $out/nix-support/build-products
            '';

          };
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          cloud = [
            pkgs.opentofu
            pkgs.backblaze-b2

          ];
        in
        {
          packages = packagesFor pkgs;
          formatter = pkgs.nixfmt-rfc-style;
          devShells = {
            default = pkgs.mkShell {
              buildInputs = (builtins.attrValues self'.packages) ++ cloud;
            };
          };
          checks.build-all =
            pkgs.runCommand "build-all"
              {
                nativeBuildInputs = builtins.attrValues self'.packages;
              }
              ''
                solc --version
                lsh --version
                solana --version
                cargo-build-sbf --version
                solana-test-validator --version
                mkdir $out
              '';
          apps = {
            build-base = {
              type = "app";
              program = pkgs.writeShellApplication {
                name = "build-base";
                runtimeInputs = [ pkgs.opentofu ];
                text = ''

                '';
              };
            };
          };
        };
      flake = {
        overlays.default = final: prev: packagesFor prev;

        nixConfig = {
          extra-substituters = [ "https://n1.cachix.org" ];
          extra-trusted-public-keys = [ "n1.cachix.org-1:vQ3RpPAz7vsJCg0PIWXYuzG+RrgV4fJ1uQkuEvcUfQI=" ];
        };

        nixosConfigurations = {
          base = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./infra/base/base.nix
              disko.nixosModules.disko
            ];
          };
        };
      };
    };
}
