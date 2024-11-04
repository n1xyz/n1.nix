# Solidity Compiler Nix Flake

This repository provides a Nix Flake setup for different Solidity compiler (`solc`) versions, with `solc-0.8.26` included as an example. This configuration is optimized for cross-platform use, supporting Linux and macOS architectures.

## Overview

- **Primary Purpose**: Manage and deploy specific versions of the Solidity compiler in a reproducible, cross-platform environment.
- **Flake Dependencies**:
  - `flake-parts`: Utilized to streamline the flake structure.
  - `nixpkgs`: Provides the base system packages for various architectures.
  - `solc-0.8.26`: Custom package for the Solidity compiler version 0.8.26, based on `nixpkgs` configurations.

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
A default development shell with solc-0.8.26 is available:

```
nix develop
```

This command loads the necessary environment and tools.

Future Directions

Expand Compatibility: Add more Solidity versions and compatibility across architectures.
Testing: Integrate additional tests to validate the cross-platform configurations.

License

Licensed under GPL-3.0, following the original solc license.
