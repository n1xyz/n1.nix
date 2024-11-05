{ stdenv, fetchurl, ... }:

stdenv.mkDerivation {
  name = "lsh-2.1";
  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/lsh/lsh-2.1.tar.gz";
    sha256 = "8bbf94b1aa77a02cac1a10350aac599b7aedda61881db16606debeef7ef212e3";
  };

  buildInputs = [ /* dependencies */ ];
  /* additional build or configure steps */
}
