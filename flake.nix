{
  description = "Various packages useful to us";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    rustfs.url = "github:rustfs/rustfs-flake";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      packagesFor =
        {
          pkgs,
          pkgsUnstable,
          rustfsUpstream,
        }:
        rec {
          spl-token = pkgs.callPackage ./spl-token.nix { };
          agave-platform-tools = pkgs.callPackage ./agave-platform-tools.nix { };
          agave-cli = pkgs.callPackage ./agave-cli.nix {
            inherit agave-platform-tools;
          };
          axiom-cli = pkgs.callPackage ./axiom-cli.nix {
            go = pkgsUnstable.go_1_26;
          };
          rustfs = pkgs.callPackage ./rustfs.nix {
            upstream = rustfsUpstream;
          };
          shank = pkgs.callPackage ./shank.nix { };
          squads-cli = pkgs.callPackage ./squads-cli.nix { };
          cargo-build-static-release = pkgs.callPackage ./packages/cargo-build-static-release.nix { };
          bun-enforce = pkgs.callPackage ./packages/bun-enforce.nix { };
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
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
          packages = packagesFor {
            inherit pkgs;
            pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages.${system};
            rustfsUpstream = inputs.rustfs.packages.${system}.default;
          };
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
        overlays.default =
          final: prev:
          packagesFor {
            pkgs = prev;
            pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.buildPlatform.system};
            rustfsUpstream = inputs.rustfs.packages.${prev.stdenv.buildPlatform.system}.default;
          };

        nixConfig = {
          extra-substituters = [ "https://n1.cachix.org" ];
          extra-trusted-public-keys = [ "n1.cachix.org-1:vQ3RpPAz7vsJCg0PIWXYuzG+RrgV4fJ1uQkuEvcUfQI=" ];
        };
      };
    };
}
