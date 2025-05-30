{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  udev,
  darwin,
}: rustPlatform.buildRustPackage {
  pname = "squads-cli";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "n1xyz";
    repo = "squads-v4";
    rev = "112e8b702be9c67d29916645b9d3abd45cecbeba";
    hash = "sha256-9qkFxaWsxMHtbd1YBQ20VD0MVHyiCWIC4nZNGKN3joA=";
  };

  cargoHash = "sha256-Z/USg35zm6B9iqpWaYzlJZ0NfsicIZ5D15NQ2n2S6NE=";
  sourceRoot = "source/cli";

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
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "squads-multisig-cli";
  };
}
