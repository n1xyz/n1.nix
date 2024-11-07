{
  description = "Test flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    layern.url = "path:../.";
  };

  outputs =
    inputs@{ flake-parts, ... }:
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
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              solc-0_8_26
              lsh
            ];
          };

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.layern.overlays.default ];
            config = { };
          };
        };
    };
}
