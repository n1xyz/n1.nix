{ stdenv, fetchurl, lib,  ... }:

stdenv.mkDerivation {
  pname = "lsh";
  version = "1.3.3";

  src = fetchurl {
    url = "https://github.com/latitudesh/lsh/releases/download/v1.3.3/lsh_Darwin_arm64.tar.gz";
    sha256 = "70550a0e5579acf267df9f24f11c51c1e9eefce003952c754503f95ee567a40d";
  };

  nativeBuildInputs = [];

  installPhase = ''
    mkdir -p $out/bin
    cp lsh $out/bin/
    chmod +x $out/bin/lsh
  '';

  meta = with lib; {
    description = "Latitude.sh lsh tool v1.3.3";
    homepage = "https://github.com/latitudesh/lsh";
    license = licenses.mit;
  };
}
