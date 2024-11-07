{
  description = "Various solc and lsh versions";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    let
      packagesFor = pkgs: {
        solc-0_8_26 = pkgs.callPackage ./solc-0.8.26.nix { };
        lsh = pkgs.callPackage ./lsh.nix { };
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
        { config
        , self'
        , inputs'
        , pkgs
        , system
        , ...
        }:
        {
          packages = packagesFor pkgs;
        };
      flake = {
        overlays.default = final: prev: packagesFor prev;
      };
    };
}
