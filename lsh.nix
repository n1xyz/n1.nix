{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "lsh";
  version = "1.3.3";

  # Fetch the source code using fetchFromGitHub
  src = fetchFromGitHub {
    owner = "latitudesh";
    repo = "lsh";
    rev = "v${version}";
    sha256 = "0YpjG4u+wb4LRWzfTddKFwut0MBzEch+HZijmZiVXpE=";
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

