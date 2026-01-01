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
  python313,
  libedit,
  udev,
}:
let
  version = "1.49";

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
          sha256 = "sha256:060nw0ircc0pcb484m8cp1g6338fm1684kzqfp9bpwm6282jds3h";
        };
        "x86_64-darwin" = {
          url = url "osx-x86_64";
          sha256 = "sha256:1lxrghwkf12vhv35yz5z285lwh01jwpdi268s1b4dbd10mcgkvvr";
        };
        "aarch64-darwin" = {
          url = url "osx-aarch64";
          sha256 = "sha256:19vsi70zmwxh6db6y6cf5bwa5vicgmk6ivk3c0xaj7c7hdq1wrh8";
        };
        "aarch64-linux" = {
          url = url "linux-aarch64";
          sha256 = "sha256:1pvjp2b6mjlnswqbwicsyz77vbddff4laigyb9clyqj8gpg0kpr1";
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
      python313
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
    '';
    installPhase = ''
      # https://github.com/anza-xyz/platform-tools/issues/79#issuecomment-2494982009
      rm -rf llvm/lib/python3.10
      rm -rf llvm/lib/python3.13

      cp -a . $out
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
