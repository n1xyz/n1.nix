{
  withSystem,
  inputs,
  self,
  ...
}: {
  flake.overlays.lib = final: prev:
    withSystem prev.stdenv.hostPlatform.system ({
      self',
      pkgs,
      ...
    }: {
      cosmosLib = let
        lib = import ../lib;
      in
        lib std {
          inherit pkgs;
        };
    });
}