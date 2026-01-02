{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "anchor";
  version = "0.31.0";

  src = fetchFromGitHub {
    owner = "solana-foundation";
    repo = "anchor";
    rev = "v${version}";
    hash = "sha256-rwf2PWHoUl8Rkmktb2u7veRrIcLT3syi7M2OZxdxjG4=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-wznmP3vXKY2jR4Ju+mjz6mMvicJoEKUYdAHVn5EI1c4=";

  checkFlags = [
    # the following test cases try to access network, skip them
    "--skip=tests::test_check_and_get_full_commit_when_full_commit"
    "--skip=tests::test_check_and_get_full_commit_when_partial_commit"
    "--skip=tests::test_get_anchor_version_from_commit"
  ];
}
