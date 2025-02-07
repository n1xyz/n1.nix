{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:
with lib;
{
  imports = [
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
    ./install.nix
  ];
}
