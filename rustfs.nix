{
  cctools,
  lib,
  stdenv,
  upstream,
  xz,
}:
if stdenv.isDarwin then
  upstream.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ cctools ];
    postFixup = (old.postFixup or "") + ''
      install_name_tool -change \
        /opt/homebrew/opt/xz/lib/liblzma.5.dylib \
        ${lib.getLib xz}/lib/liblzma.5.dylib \
        $out/bin/rustfs
    '';
  })
else
  upstream
