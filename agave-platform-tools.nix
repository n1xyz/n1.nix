{
  lib,
  stdenv,
  autoPatchelfHook,
  fixDarwinDylibNames,
  gnutar,
  zlib,
  openssl,
  libclang,
  xz,
  python312,
  libedit,
  udev,
}:
let
  version = "1.43";

  src =
    let
      url =
        os-arch:
        "https://github.com/anza-xyz/platform-tools/releases/download/v${version}/platform-tools-${os-arch}.tar.bz2";
    in
    builtins.fetchurl
      {
        "x86_64-linux" = {
          url = url "linux-x86_64";
          sha256 = "sha256:1xm89jk7bybyydal0bdss6ss07pr90xa19fhwbpghjs8l1s72jbs";
        };
        "aarch64-darwin" = {
          url = url "osx-aarch64";
          sha256 = "sha256:0s9f99c0sy09gx2hq4d5qlwc4p3mxy0bjc8yza7wi0c7hrvq6v6z";
        };
        "x86_64-darwin" = {
          url = url "osx-x86_64";
          sha256 = "sha256:0jsd9938kfyx972730hfh089fkgjl8iwrdd74spbn4lr8ncckn98";
        };
        "aarch64-linux" = {
          url = url "linux-aarch64";
          sha256 = "sha256:0q9ihr5xn2lb8nbl0jwapp2958hl9nx3jxs3pdrhvng4i7h5mqx3";
        };
      }
      .${stdenv.hostPlatform.system};
  agave-platform-tools = stdenv.mkDerivation {
    pname = "agave-platform-tools";
    inherit version src;
    buildInputs = [
      gnutar
      zlib
      stdenv.cc.cc
      openssl
      libclang.lib
      xz
      python312
      libedit
    ] ++ lib.optionals stdenv.isLinux [ udev ];
    nativeBuildInputs = [
      (lib.optional (!stdenv.hostPlatform.isDarwin) autoPatchelfHook)
      (lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames)
    ];
    autoPatchelfIgnoreMissingDeps = [
      "libedit.so.2"
      "libpython3.10.so.1.0"
    ];
    # We need to preserve metadata in .rlib, which might get stripped on macOS.
    # See https://github.com/NixOS/nixpkgs/issues/218712
    stripExclude = [ "*.rlib" ];
    sourceRoot = ".";
    unpackPhase = ''
      tar -xjf $src

      # https://github.com/anza-xyz/platform-tools/issues/79#issuecomment-2494982009
      rm -rf llvm/lib/python3.12
    '';
    installPhase = ''
      cp -a  . $out
    '';
  };
in
agave-platform-tools
// {
  llvm = stdenv.mkDerivation {
    pname = "agave-platform-tools-llvm";
    inherit version;
    src = agave-platform-tools;
    # We need to preserve metadata in .rlib, which might get stripped on macOS.
    # See https://github.com/NixOS/nixpkgs/issues/218712
    stripExclude = [ "*.rlib" ];
    buildInputs = [ agave-platform-tools ];
    installPhase = ''
      cp -a $src/llvm $out
    '';
  };
  rust = stdenv.mkDerivation {
    pname = "agave-platform-tools-rust";
    inherit version;
    src = agave-platform-tools;
    # We need to preserve metadata in .rlib, which might get stripped on macOS.
    # See https://github.com/NixOS/nixpkgs/issues/218712
    stripExclude = [ "*.rlib" ];
    buildInputs = [ agave-platform-tools ];
    installPhase = ''
      cp -a $src/rust $out
    '';
  };
}
