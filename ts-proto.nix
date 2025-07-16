{
  stdenv,
  lib,
  fetchFromGitHub,
  nodejs,
  yarn-berry_4,
  protobuf,
}:
let
  yarn-berry = yarn-berry_4;
  pname = "ts-proto";
  version = "2.7.5";
  src = fetchFromGitHub {
    owner = "stephenh";
    repo = "ts-proto";
    rev = "v${version}";
    sha256 = "sha256-k76UtnsKxzZFaQmPd4HJEi8aX7M23TMLig1kAyEOMmU=";
  };
  # computed with pkgs.yarn-berry_4.yarn-berry-fetcher.
  # use `missing-hashes` subcommand.
  missingHashes = ./ts-proto.missing-hashes.json;
in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    missingHashes
    ;

  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit src missingHashes;
    hash = "sha256-duDYbEVbRlNpF7pzLgQWrSjG00CRHR0E051RzrjcLwQ=Z";
  };

  nativeBuildInputs = [
    nodejs
    yarn-berry
    yarn-berry.yarnBerryConfigHook
  ];

  checkInputs = [
    protobuf
  ];

  buildPhase = ''
    yarn build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp protoc-gen-ts_proto $out/bin
  '';

  checkPhase = ''
    cat <<EOF > test.proto
    syntax = "proto3";
    message Test {
      string name = 1;
    }
    EOF
    protoc \
      --plugin=protoc-gen-ts_proto=$out/bin/protoc-gen-ts_proto \
      --ts_proto_out=$(mktemp -d) \
      test.proto
  '';
}
