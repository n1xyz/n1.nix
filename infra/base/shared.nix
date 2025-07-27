# configs shared amid all boot and install images
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
  config = {
    environment = {
      systemPackages = [
        pkgs.curl
        pkgs.nano
        pkgs.util-linux
      ];
    };





  };
}
