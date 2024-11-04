# Solidity Compiler Nix Flake

This repository includes packages that we use that are not provided in nixpkgs or that require specific versions.

## System Compatibility

This flake is configured to support:
- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin`
- `aarch64-darwin`

## Repository Structure

- `flake.nix`: Defines the main flake configuration, including system compatibility and package versions.
- `solc-0.8.26.nix`: Custom derivation for `solc-0.8.26`, with dependencies and build instructions.
- `test/flake.nix`: Example test flake for verifying configurations across environments.

## Usage

To use this repository, make sure `nix` is installed with support for flakes enabled. Configure `nix.conf` as follows if not already set:

```bash
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Building solc
Use the following command to build solc-0.8.26:

```
nix build .#packages.x86_64-linux.solc-0_8_26
```

Replace x86_64-linux with the appropriate system architecture if needed.

Development Shell

```
$ nix develop ./test
```

This command loads the necessary environment and tools.

Future Directions

Expand Compatibility: Add more Solidity versions and compatibility across architectures.
Testing: add CI checks.
