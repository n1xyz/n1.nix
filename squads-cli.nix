{ stdenv, lib, fetchFromGitHub, rustPlatform, pkg-config, openssl, darwin, }:
let
  version = "4.0.0";
  rev = "4f864f8ff1bfabaa0d7367ae33de085e9fe202cf"; # Specific commit
  srcHash = "sha256-30rDBZhPLxOmxBt3vHhI3D4O5EMPd0rDOne2Z0coRZU=";
  cargoPatches = [ ./squads-cli.Cargo.lock.patch ];
  cargoHash = "sha256-qkpPLqoFeUiQj8eyvu+4PDZSsnJCYGeWT8Ie9uC6am4=";
in rustPlatform.buildRustPackage {
  pname = "squads-cli";
  inherit version cargoHash;

  src = fetchFromGitHub {
    owner = "Squads-Protocol";
    repo = "v4";
    inherit rev;
    hash = srcHash;
  };

  sourceRoot = "source/cli";

  # Skip tests as they may require a Solana validator to run
  doCheck = false;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  meta = with lib; {
    description = "CLI for Squads Protocol v4";
    homepage = "https://github.com/Squads-Protocol/v4";
    license = licenses.agpl3Only;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "squads-cli";
  };
}
