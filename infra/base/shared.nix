# configs shared amid all boot and install images
{
  config,
  lib,
  specialArgs,
  options,
  modulesPath,
  pkgs,
}:
{
  config = {
    environment = {
      systemPackages = [
        pkgs.disko
        pkgs.curl
        pkgs.git
        pkgs.nano
      ];
    };
    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org/"
        "https://cache.nixos.org/"
        "https://nixpkgs-update.cachix.org"
      ];

      trusted-public-keys = [
        "nixpkgs-update.cachix.org-1:6y6Z2JdoL3APdu6/+Iy8eZX2ajf09e4EE9SnxSML1W8="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    services.openssh.enable = true;
    services.sshd.enable = true;
    users.users.n1 = {
      isNormalUser = true;
      home = "/home/n1";
      extraGroups = [
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/PGg+j/Y5gP/e7zyMCyK+f0YfImZgKZ3IUUWmkoGtT dzmitry@nullstudios.xyz"
      ];
    };
  };
}
