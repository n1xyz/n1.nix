{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
let
  version = "0.4.2";
  srcHash = "sha256-jw6hZjDWPUBFkmHkX9ucChmrveaUQ2xYoKsmyBoxmWw=";

  # absent Cargo.lock requires using cargoPatches. don't forget
  # to set `cargoHash = lib.fakeHash` when updating. steps:
  #
  # $ mkdir b/
  # $ cp Cargo.lock b/
  # $ diff -Nu a/Cargo.lock b/Cargo.lock > shank.Cargo.lock.patch
  cargoPatches = [ ./shank.Cargo.lock.patch ];
  cargoHash = "sha256-JhkEntDGddVXvY8eJ6xipbOsJ4JP3NeOkbTtN0maf7A=";
in
rustPlatform.buildRustPackage {
  src = fetchFromGitHub {
    owner = "metaplex-foundation";
    repo = "shank";
    rev = "shank-cli@v${version}";
    hash = srcHash;
  };

  inherit version cargoPatches cargoHash;
  pname = "shank";
  buildAndTestSubdir = "shank-cli";
  useFetchCargoVendor = true;
}
