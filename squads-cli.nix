{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  udev,
  darwin,
}:
let
  version = "4.0.0";
  rev = "4f864f8ff1bfabaa0d7367ae33de085e9fe202cf"; # Specific commit
  srcHash = "sha256-30rDBZhPLxOmxBt3vHhI3D4O5EMPd0rDOne2Z0coRZU=";
  cargoHash = "sha256-gD7WzWMadmVLaK9dn55WBsOi5rqFPavJHBq0RZSBbdw=";
in
rustPlatform.buildRustPackage {
  pname = "squads-cli";
  inherit version cargoHash;

  src = fetchFromGitHub {
    owner = "Squads-Protocol";
    repo = "v4";
    inherit rev;
    hash = srcHash;
  };

  sourceRoot = "source/cli";

  cargoPatches = [ ./squads-cli.Cargo.lock.patch ];

  # Enable vendoring to ensure we use our patched dependencies
  useFetchCargoVendor = true;

  # Skip tests as they may require a Solana validator to run
  doCheck = false;

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.isLinux [ udev ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  meta = with lib; {
    description = "CLI for Squads Protocol v4";
    homepage = "https://github.com/Squads-Protocol/v4";
    license = licenses.agpl3Only;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "squads-multisig-cli";
  };
}
