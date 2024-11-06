{ lib, buildGoModule, fetchurl }:

buildGoModule rec {
  pname = "lsh";
  version = "1.3.3";

  # Fetch the source code using fetchurl
  src = fetchurl {
    url = "https://github.com/latitudesh/lsh/archive/refs/tags/v${version}.tar.gz";
    sha256 = "552f56cc6773d1a3eb7e8ff8ae859a5226e5a321bf7f7fe2529db18be1e6d498";
  };
  vendorHash = "sha256-ogdyzfayleka4Y8x74ZtttD7MaeCl1qP/rQi9x0tMto=";

  subPackages = [ "." ];

  # Metadata
  meta = with lib; {
    description = "Latitude.sh lsh tool v${version}";
    homepage = "https://github.com/latitudesh/lsh";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
