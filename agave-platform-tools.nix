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
  version = "1.44";

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
          sha256 = "sha256:1sdk12l6fjpqx7px5vckn05gw6hs8il2zj7lzjiahxq6ss4vh6b7";
        };
        "aarch64-darwin" = {
          url = url "osx-aarch64";
          sha256 = "sha256:0lckswxb4vbm4c7ab4yzmvwmfabn1lrgzxxs37shzmyxbw9hvqk6";
        };
        "aarch64-linux" = {
          url = url "linux-aarch64";
          sha256 = "sha256:13ckf763pvkpnz1nail6bkg2n0zh4mrzj9nixir5y3c5xvq6nx1m";
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
