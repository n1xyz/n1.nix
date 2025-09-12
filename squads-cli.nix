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
    rev = "253ad4bfc992ef97b3f96eb2c19292ef5057123c";
    hash = "sha256-yQNi16U8AG1oI8NV9dioraPdEN3d+/tC7DW3L8hvt0o=";
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
