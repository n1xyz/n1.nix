# Adapted from https://github.com/NixOS/nixpkgs/blob/edf04b75c13c2ac0e54df5ec5c543e300f76f1c9/pkgs/by-name/so/solana-cli/package.nix
let
  allSolanaPkgs = [
    "solana"
    "solana-faucet"
    "solana-genesis"
    "solana-gossip"
    "agave-install"
    "solana-keygen"
    "solana-net-shaper"
    "agave-validator"
    "solana-test-validator"
    "cargo-build-sbf"
    "cargo-test-sbf"
    "agave-install-init"
    "solana-stake-accounts"
    "solana-tokens"
    "agave-watchtower"
  ];
  # dev-context-only-utils
  # NOTE: keep this in sync with latest https://github.com/anza-xyz/agave/blob/5bcdd4934475fde094ffbddd3f8c4067238dc9b0/scripts/dcou-tainted-packages.sh
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
  libcxx,
  rocksdb_9_10,
  makeWrapper,
  installShellFiles,
  pkg-config,
  openssl,
  nix-update-script,
  agave-platform-tools,
  solanaPkgs ? allSolanaPkgs,
  solanaDcouPkgs ? allSolanaDcouPkgs,
}:
let
  version = "3.0.0";
  srcHash = "sha256-jePab51kL2r6EsopKKSYOadPnc7GBoqvSk88GLf00DE=";
  cargoHash = "sha256-hPJvIkB+tGxtUQa8JoWPHqndft0ZenjJogVYx0Vq8ZE=";
  # rust-rocksdb v0.23.0 supports v9.9.3. on nixpkgs 9.10 is the closest.
  # https://github.com/rust-rocksdb/rust-rocksdb/blob/v0.23.0/librocksdb-sys/Cargo.toml
  rocksdb = rocksdb_9_10;
in
rustPlatform.buildRustPackage rec {
  inherit
    version
    cargoHash
    ;

  pname = "solana-cli";

  src = fetchFromGitHub {
    owner = "anza-xyz";
    repo = "agave";
    rev = "v${version}";
    hash = srcHash;
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
    rustPlatform.bindgenHook
    agave-platform-tools
  ];
  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ udev ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ libcxx ];

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
          --manifest-path syscalls/gen-syscall-list/Cargo.toml

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

    mkdir -p $out/bin/platform-tools-sdk/sbf
    cp -a ./platform-tools-sdk/sbf/* $out/bin/platform-tools-sdk/sbf

    # replicate platform tool installation logic. they install the platform tools
    # to ~/.cache/solana/{version}/platform-tools and create a symlink to it. we
    # install it to the store and create a symlink to that instead.
    #
    # https://github.com/anza-xyz/agave/blob/v3.0.0/platform-tools-sdk/cargo-build-sbf/src/toolchain.rs#L382
    mkdir -p $out/bin/platform-tools-sdk/sbf/dependencies
    ln -s ${agave-platform-tools} $out/bin/platform-tools-sdk/sbf/dependencies/platform-tools
  '';

  postFixup = ''
    # This rustc supports the necesary sbf-solana-solana target.
    wrapProgram $out/bin/cargo-build-sbf \
      --set-default RUSTC "${agave-platform-tools}/rust/bin/rustc"
  '';

  # Require this on darwin otherwise the compiler starts rambling about missing
  # cmath functions
  CPPFLAGS = lib.optionals stdenv.hostPlatform.isDarwin "-isystem ${lib.getDev libcxx}/include/c++/v1";
  LDFLAGS = lib.optionals stdenv.hostPlatform.isDarwin "-L${lib.getLib libcxx}/lib";

  # Used by build.rs in the rocksdb-sys crate. If we don't set these, it would
  # try to build RocksDB from source.
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";

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
