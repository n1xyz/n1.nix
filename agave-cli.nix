# Adapted from https://github.com/NixOS/nixpkgs/blob/edf04b75c13c2ac0e54df5ec5c543e300f76f1c9/pkgs/by-name/so/solana-cli/package.nix
let
  # https://github.com/anza-xyz/agave/blob/f3960f4632860b8fbae51cd419e20afaba18c34e/scripts/agave-build-lists.sh#L46-L57
  # note: this list is newer than the one for the version installed here, but i found it easier to reference.
  allSolanaPkgs = [
    "cargo-build-sbf"
    "cargo-test-sbf"
    "solana-test-validator"

    "agave-install"
    "solana"
    "solana-keygen"

    "agave-validator"
    "agave-watchtower"
    "solana-gossip"
    "solana-genesis"
    "solana-faucet"

    "solana-log-analyzer"
    "solana-net-shaper"
  ];
  # dev-context-only-utils
  allSolanaDcouPkgs = [
    "agave-ledger-tool"
    "agave-store-histogram"
    "agave-store-tool"
    "solana-accounts-cluster-bench"
    "solana-banking-bench"
    "solana-bench-tps"
    "solana-dos"
    "solana-transaction-dos"
    "solana-vortexor"
  ];
in
{
  stdenv,
  fetchFromGitHub,
  lib,
  rustPlatform,
  rust,
  darwin,
  udev,
  protobuf,
  clang,
  libclang,
  rocksdb_8_11,
  makeWrapper,
  installShellFiles,
  pkg-config,
  openssl,
  zlib,
  nix-update-script,
  agave-platform-tools,
  solanaPkgs ? allSolanaPkgs,
  solanaDcouPkgs ? allSolanaDcouPkgs,
}:
let
  # https://github.com/anza-xyz/agave/pull/4061
  version = "2.3.13";
  hash = "sha256-RSucqvbshaaby4fALhAQJtZztwsRdA+X7yRnoBxQvsg=";
  # NOTE: should be 8.10.0, but let's try 8.11.0 for now
  rocksdb = rocksdb_8_11;
in
rustPlatform.buildRustPackage rec {
  pname = "solana-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "anza-xyz";
    repo = "agave";
    rev = "v${version}";
    inherit hash;
  };

  cargoLock = {
    lockFile = ./agave-cli.Cargo.lock;

    outputHashes = {
      "crossbeam-epoch-0.9.5" = "sha256-Jf0RarsgJiXiZ+ddy0vp4jQ59J9m0k3sgXhWhCdhgws=";
      "quinn-0.11.8" = "sha256-bjO72BMpW6frEti9UdE0VAlsetgDSjF72Sq20NW0ayI=";
    };
  };

  strictDeps = true;

  # Even tho the tests work, a shit ton of them try to connect to a local RPC
  # or access internet in other ways, eventually failing due to Nix sandbox.
  # Maybe we could restrict the check to the tests that don't require an RPC,
  # but judging by the quantity of tests, that seems like a lengthty work and
  # I'm not in the mood ((ΦωΦ))
  doCheck = false;

  # We need to preserve metadata in .rlib, which might get stripped on macOS.
  # See https://github.com/NixOS/nixpkgs/issues/218712
  stripExclude = [ "*.rlib" ];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    protobuf
    pkg-config
    agave-platform-tools
  ];
  buildInputs = [
    openssl
    zlib
    clang
    libclang
    rustPlatform.bindgenHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ udev ];

  buildPhase = ''
    runHook preBuild
    (
      # avoid running the hooks twice
      unset preBuildHook
      unset preBuildHooks
      unset postBuildHook
      unset postBuildHooks

      ${lib.strings.toShellVar "cargoBuildFlags" (
        (builtins.map (n: "--bin=${n}") solanaPkgs)
        ++ [ "--workspace" ]
        ++ (builtins.map (n: "--exclude=${n}") allSolanaDcouPkgs)
      )}
      cargoBuildHook

      ${lib.strings.toShellVar "cargoBuildFlags" (builtins.map (n: "--bin=${n}") solanaDcouPkgs)}
      cargoBuildHook

      ${rust.envVars.setEnv} cargo build \
          -j "$NIX_BUILD_CORES" \
          --target "${rust.envVars.rustHostPlatformSpec}" \
          --offline \
          --manifest-path programs/bpf_loader/gen-syscall-list/Cargo.toml

      ${rust.envVars.setEnv} cargo run \
          -j "$NIX_BUILD_CORES" \
          --target "${rust.envVars.rustHostPlatformSpec}" \
          --offline \
          --bin gen-headers
    )
    runHook postBuild
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd solana \
      --bash <($out/bin/solana completion --shell bash) \
      --fish <($out/bin/solana completion --shell fish)

    mkdir -p $out/bin/platform-tools-sdk
    cp -r ./platform-tools-sdk/sbf $out/bin/platform-tools-sdk

    mkdir -p $out/bin/deps
    find . -name libsolana_program.dylib -exec cp {} $out/bin/deps \;
    find . -name libsolana_program.rlib -exec cp {} $out/bin/deps \;
  '';

  postFixup = ''
    # This rustc supports the necesary sbf-solana-solana target.
    wrapProgram $out/bin/cargo-build-sbf \
      --set-default RUSTC "${agave-platform-tools}/rust/bin/rustc"
  '';

  RUSTFLAGS = "-Amismatched_lifetime_syntaxes -Adead_code -Aunused_parens";
  LIBCLANG_PATH = "${libclang.lib}/lib";

  # Used by build.rs in the rocksdb-sys crate. If we don't set these, it would
  # try to build RocksDB from source.
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";

  # Require this on darwin otherwise the compiler starts rambling about missing
  # cmath functions
  CPPFLAGS = lib.optionals stdenv.hostPlatform.isDarwin "-isystem ${lib.getInclude stdenv.cc.libcxx}/include/c++/v1";
  LDFLAGS = lib.optionals stdenv.hostPlatform.isDarwin "-L${lib.getLib stdenv.cc.libcxx}/lib";

  # If set, always finds OpenSSL in the system, even if the vendored feature is enabled.
  OPENSSL_NO_VENDOR = 1;

  meta = with lib; {
    description = "Web-Scale Blockchain for fast, secure, scalable, decentralized apps and marketplaces";
    homepage = "https://www.anza.xyz";
    license = licenses.asl20;
    platforms = platforms.unix;
  };

  passthru.updateScript = nix-update-script { };
}
