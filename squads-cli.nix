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
rustPlatform.buildRustPackage {
  pname = "squads-cli";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "n1xyz";
    repo = "squads-v4";
    rev = "cc293c6d66900165462e4fabbc8d82aeb13c6940";
    hash = "sha256-aDGbUbofxZ/PhxesDVvtIZQUk3o1isiVWA34pON1JIc=";
  };

  cargoHash = "sha256-NXJdCOfnge7e/e8Hut8M410JLnNqghA0e4UIx2ZC0sQ=";
  sourceRoot = "source/cli";

  # Skip tests as they may require a Solana validator to run
  doCheck = false;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ] ++ lib.optionals stdenv.isLinux [ udev ];

  meta = with lib; {
    description = "CLI for Squads Protocol v4";
    homepage = "https://github.com/Squads-Protocol/v4";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "squads-multisig-cli";
  };
}
