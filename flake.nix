{
  description = "Various solc and lsh versions";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    let
      packagesFor = pkgs: rec {
        solc-0_8_26 = pkgs.callPackage ./solc-0.8.26.nix { };
        lsh = pkgs.callPackage ./lsh.nix { };
        spl-token = pkgs.callPackage ./spl-token.nix { };
        agave-platform-tools = pkgs.callPackage ./agave-platform-tools.nix { };
        agave-cli = pkgs.callPackage ./agave-cli.nix {
          inherit agave-platform-tools;
        };
        shank = pkgs.callPackage ./shank.nix { };
        squads-cli = pkgs.callPackage ./squads-cli.nix { };
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
        {
          packages = packagesFor pkgs;
          formatter = pkgs.nixfmt-rfc-style;
          devShells.default = pkgs.mkShell {
            # yarn-berry-fetcher used to compute yarn missing-hashes.json
            buildInputs = builtins.attrValues self'.packages;
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
                spl-token --version
                shank --version
                squads-multisig-cli --help
                mkdir $out
              '';
        };
      flake = {
        overlays.default = final: prev: packagesFor prev;

        nixConfig = {
          extra-substituters = [ "https://n1.cachix.org" ];
          extra-trusted-public-keys = [ "n1.cachix.org-1:vQ3RpPAz7vsJCg0PIWXYuzG+RrgV4fJ1uQkuEvcUfQI=" ];
        };
      };
    };
}
