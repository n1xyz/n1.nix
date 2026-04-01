{
  buildGoModule,
  fetchFromGitHub,
  lib,
  go,
}:
(buildGoModule.override { inherit go; }) rec {
  pname = "axiom-cli";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "axiomhq";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-3JK9HEuVyRTe+HqbJZVDHTkFI054ETkeX2H7yYGxlVE=";
  };

  vendorHash = "sha256-BRvnoyojLcjUVppUaC7zVJasrd50X1gyufCw3hdgEMQ=";
  subPackages = [ "cmd/axiom" ];
  doCheck = false;

  meta = with lib; {
    description = "Axiom command line client";
    homepage = "https://github.com/axiomhq/cli";
    license = licenses.mit;
    mainProgram = "axiom";
  };
}
