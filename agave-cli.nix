# Adapted from https://github.com/NixOS/nixpkgs/blob/edf04b75c13c2ac0e54df5ec5c543e300f76f1c9/pkgs/by-name/so/solana-cli/package.nix
{
  stdenv,
  fetchFromGitHub,
  lib,
  rustPlatform,
  darwin,
  udev,
  protobuf,
  libcxx,
  rocksdb_8_11,
  installShellFiles,
  pkg-config,
  openssl,
  nix-update-script,
  # Taken from https://github.com/solana-labs/solana/blob/master/scripts/cargo-install-all.sh#L84
  solanaPkgs ?
    [
      "solana"
      "solana-bench-tps"
      "solana-faucet"
      "solana-gossip"
      "agave-install"
      "solana-keygen"
      "agave-ledger-tool"
      "solana-log-analyzer"
      "solana-net-shaper"
      "agave-validator"
      "solana-test-validator"
    ]
    ++ [
      # XXX: Ensure `solana-genesis` is built LAST!
      # See https://github.com/solana-labs/solana/issues/5826
      "solana-genesis"
    ],
}:
let
  version = "2.0.21";
  hash = "sha256-XmkWdJQXT8VFadfY675qs98MwlHjX8DkZLD9x6nrOWE=";
  # NOTE: should be 8.10.0, but let's try 8.11.0 for now
  rocksdb = rocksdb_8_11;

  inherit (darwin.apple_sdk_11_0) Libsystem;
  inherit (darwin.apple_sdk_11_0.frameworks)
    System
    IOKit
    AppKit
    Security
    ;
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
      "tokio-1.29.1" = "sha256-Z/kewMCqkPVTXdoBcSaFKG5GSQAdkdpj3mAzLLCjjGk=";
      "curve25519-dalek-3.2.1" = "sha256-4MF/qaP+EhfYoRETqnwtaCKC1tnUJlBCxeOPCnKrTwQ=";
    };
  };

  strictDeps = true;
  cargoBuildFlags = builtins.map (n: "--bin=${n}") solanaPkgs;

  # Even tho the tests work, a shit ton of them try to connect to a local RPC
  # or access internet in other ways, eventually failing due to Nix sandbox.
  # Maybe we could restrict the check to the tests that don't require an RPC,
  # but judging by the quantity of tests, that seems like a lengthty work and
  # I'm not in the mood ((ΦωΦ))
  doCheck = false;

  nativeBuildInputs = [
    installShellFiles
    protobuf
    pkg-config
  ];
  buildInputs =
    [
      openssl
      rustPlatform.bindgenHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ udev ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libcxx
      IOKit
      Security
      AppKit
      System
      Libsystem
    ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd solana \
      --bash <($out/bin/solana completion --shell bash) \
      --fish <($out/bin/solana completion --shell fish)

    mkdir -p $out/bin/sdk/bpf
    cp -a ./sdk/bpf/* $out/bin/sdk/bpf/
  '';

  # Used by build.rs in the rocksdb-sys crate. If we don't set these, it would
  # try to build RocksDB from source.
  ROCKSDB_LIB_DIR = "${rocksdb}/lib";

  # Require this on darwin otherwise the compiler starts rambling about missing
  # cmath functions
  CPPFLAGS = lib.optionals stdenv.hostPlatform.isDarwin "-isystem ${lib.getDev libcxx}/include/c++/v1";
  LDFLAGS = lib.optionals stdenv.hostPlatform.isDarwin "-L${lib.getLib libcxx}/lib";

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
