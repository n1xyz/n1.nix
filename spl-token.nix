{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  protobuf,
  openssl,
  udev,
  libclang,
  rocksdb_8_11,
  snappy,
}:
let
  version = "5.1.0";
  pname = "spl-token";
  srcHash = "sha256-XqQgTbiiLKHSTInxdRh1SYgtwxcyr9Q9XJPx9+tDRwc=";
  cargoHash = "sha256-e07bJvN0+Hhd8qzhr91Ft8JjzIdkxNNkaRofj01oM2c=";
in
rustPlatform.buildRustPackage {
  src = fetchFromGitHub {
    owner = "solana-program";
    repo = "token-2022";
    rev = "cli@v${version}";
    hash = srcHash;
  };

  useFetchCargoVendor = true;
  inherit pname version cargoHash;

  nativeBuildInputs = [
    pkg-config
    protobuf
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    rocksdb_8_11
    snappy
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [ udev ];

  # don't make me do this
  doCheck = false;

  # avoid building rocksdb from source
  # https://github.com/rust-rocksdb/rust-rocksdb/blob/master/librocksdb-sys/build.rs
  ROCKSDB_LIB_DIR = "${rocksdb_8_11}/lib";
  SNAPPY_LIB_DIR = "${snappy}/lib";

  # https://docs.rs/openssl/latest/openssl/#manual
  OPENSSL_NO_VENDOR = 1;
  OPENSSL_STATIC = 1;
}
