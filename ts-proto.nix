{
  stdenv,
  lib,
  fetchFromGitHub,
  nodejs,
  yarn-berry_4,
  protobuf,
  makeWrapper,
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
    hash = "sha256-duDYbEVbRlNpF7pzLgQWrSjG00CRHR0E051RzrjcLwQ=";
  };

  nativeBuildInputs = [
    nodejs
    yarn-berry
    yarn-berry.yarnBerryConfigHook
    makeWrapper
  ];

  nativeCheckInputs = [
    protobuf
  ];

  installCheckInputs = [
    protobuf
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    yarn build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # install the entire package structure including dependencies
    mkdir -p $out/lib/node_modules/ts-proto
    cp -r build package.json protoc-gen-ts_proto node_modules $out/lib/node_modules/ts-proto/

    # make the script executable
    chmod +x $out/lib/node_modules/ts-proto/protoc-gen-ts_proto

    # create the binary wrapper that sets NODE_PATH
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/protoc-gen-ts_proto \
      --add-flags "$out/lib/node_modules/ts-proto/protoc-gen-ts_proto" \
      --set NODE_PATH "$out/lib/node_modules/ts-proto/node_modules"

    runHook postInstall
  '';

  # run check after install
  doCheck = false;
  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    # create a test proto file
    cat <<EOF > test.proto
    syntax = "proto3";
    package test;

    message TestMessage {
      string name = 1;
      int32 id = 2;
    }
    EOF

    # test the binary works
    export PATH=$out/bin:$PATH

    protoc \
      --plugin=protoc-gen-ts_proto=$out/bin/protoc-gen-ts_proto \
      --ts_proto_out=$(mktemp -d) \
      test.proto

    echo "protoc-gen-ts_proto test passed"

    runHook postInstallCheck
  '';
}
