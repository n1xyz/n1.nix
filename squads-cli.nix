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
    rev = "f1e0b661466a25b8eb6101320fcab265f009afd2";
    hash = "sha256-kMQGuAS1oPAlk9iyuudRbjVPFWmnVRvBOIuEi1jBqGY=";
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
