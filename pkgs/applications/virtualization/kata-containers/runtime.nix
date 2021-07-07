{ lib, pname, version, src, meta, stdenv, go, git, bash }:
stdenv.mkDerivation {
  pname = "${pname}-runtime";
  inherit version src;
  sourceRoot = "source/src/runtime";

  postPatch = ''
    substituteInPlace ../../ci/go-no-os-exit.sh \
      --replace /bin/bash ${bash}/bin/bash
  '';

  preConfigure = ''
    export GOCACHE=$TMPDIR/go-cache
  '';

  nativeBuildInputs = [ go git ];

  makeFlags = [ "PREFIX=$(out)" ];

  doCheck = true;

  meta = meta // {
    description = "kata-containers host runtime";
  };
}
