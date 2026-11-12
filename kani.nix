# Kani Rust model checker, from the prebuilt release bundle.
#
# Upstream's `kani-verifier` crate is only a proxy that, on first run, downloads
# this bundle to `~/.kani` and installs a pinned nightly via rustup (`cargo kani
# setup`). Here the bundle and the nightly are fixed-output nix inputs instead,
# laid out the way `kani-driver` expects a release install to look:
#
#   $out/lib/kani/bin/kani-driver   (install dir = parent of the binary's bin/)
#   $out/lib/kani/toolchain         -> nightly rust (cargo, librustc_driver)
#
# When bumping `version`, set `rust-toolchain` in flake.nix to the nightly in the
# bundle's `rust-toolchain-version` file; the install check fails otherwise.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  # nightly matching the bundle's `rust-toolchain-version`. kani ships its own
  # std, so the minimal profile is enough; kani-compiler links librustc_driver
  # from the toolchain's lib/.
  rust-toolchain,
}:
let
  version = "0.68.0";

  src =
    let
      url =
        target:
        "https://github.com/model-checking/kani/releases/download/kani-${version}/kani-${version}-${target}.tar.gz";
    in
    fetchurl
      {
        "x86_64-linux" = {
          url = url "x86_64-unknown-linux-gnu";
          sha256 = "sha256:1ls3g2pfk3a4gpk4xv4agm4j5515qiwhikx2cjzhppiysy2b9qij";
        };
        "aarch64-linux" = {
          url = url "aarch64-unknown-linux-gnu";
          sha256 = "sha256:0b4l3baz480192slmjqq31iki8gfmab9r9zlvrq04mgiidld4hh0";
        };
        "aarch64-darwin" = {
          url = url "aarch64-apple-darwin";
          sha256 = "sha256:1663l3nz4zqxd4r5x3m24xwji5y3qsaz4qmaafjm70klbrfrmlx5";
        };
      }
      .${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "kani";
  inherit version src;

  nativeBuildInputs = [ makeWrapper ] ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  # linux: the bundled cbmc tools need libstdc++, and kani-compiler needs
  # librustc_driver from the toolchain. on darwin kani-compiler finds the latter
  # via its `@loader_path/../toolchain/lib` rpath.
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    rust-toolchain
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;
  # the bundle holds precompiled rlibs whose metadata must not be stripped.
  # See https://github.com/NixOS/nixpkgs/issues/218712
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin $out/libexec/kani/bin
    cp -r . $out/lib/kani
    ln -s ${rust-toolchain} $out/lib/kani/toolchain

    # goto-cc shells out to `gcc` to preprocess C. darwin's stdenv.cc has no
    # `gcc`, and `/usr/bin/gcc` breaks when DEVELOPER_DIR points at a nix
    # apple-sdk (as in nix devshells), so always provide one.
    ln -s ${stdenv.cc}/bin/cc $out/libexec/kani/bin/gcc

    # mirrors what the upstream proxy does before exec'ing kani-driver: kani's
    # bin and its toolchain go first on PATH, and `--argv0` selects between
    # `kani` and `cargo kani` mode. the toolchain is put on PATH directly rather
    # than via RUSTUP_TOOLCHAIN, so rustup is never asked to install anything.
    for bin in kani cargo-kani; do
      makeWrapper $out/lib/kani/bin/kani-driver $out/bin/$bin \
        --argv0 $bin \
        --prefix PATH : $out/lib/kani/bin:${rust-toolchain}/bin:$out/libexec/kani/bin
    done

    runHook postInstall
  '';

  # kani-compiler only loads with the exact rustc the bundle was built with.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    expected=$(cat $out/lib/kani/rustc-version)
    actual=$(${rust-toolchain}/bin/rustc --version)
    if [[ "$expected" != "$actual" ]]; then
      echo "kani ${version} was built with '$expected', but rust-toolchain is '$actual'" >&2
      exit 1
    fi
    $out/bin/kani --version
    $out/bin/cargo-kani --version

    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Bit-precise model checker for Rust";
    homepage = "https://github.com/model-checking/kani";
    license = with licenses; [
      asl20
      mit
    ];
    mainProgram = "cargo-kani";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
