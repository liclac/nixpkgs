{ lib, newScope, fetchFromGitHub }:
let
  args = {
    pname = "kata-containers";
    version = "2.1.1";
    src = fetchFromGitHub {
      owner = "kata-containers";
      repo = "kata-containers";
      rev = "0e2be438bdd6d213ac4a3d7d300a5757c4137799";
      sha256 = "144l3x797njk84h1qk07j4502jdzw13wimxnw1xybr08b45brnh6";
      fetchSubmodules = false;
    };
    meta = with lib; {
      homepage = "https://katacontainers.io/";
      license = licenses.asl20;
      maintainers = with maintainers; [ embr ];
      platforms = platforms.linux;
    };
  };

  callPackage = newScope self;
  self = {
    agent = callPackage ./agent.nix args;
  };
in
self
