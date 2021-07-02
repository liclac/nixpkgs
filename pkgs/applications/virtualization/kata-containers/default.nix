{ lib, fetchFromGitHub, fetchpatch, stdenv, rustPlatform, kmod, coreutils }:
let
  pname = "kata-containers";
  version = "2.1.1";
  src = fetchFromGitHub {
    owner = "kata-containers";
    repo = "kata-containers";
    rev = "0e2be438bdd6d213ac4a3d7d300a5757c4137799";
    sha256 = "144l3x797njk84h1qk07j4502jdzw13wimxnw1xybr08b45brnh6";
    fetchSubmodules = false;
  };
in
{
  agent = rustPlatform.buildRustPackage {
    pname = "${pname}-agent";
    inherit version src;
    sourceRoot = "source/src/agent";
    cargoSha256 = "07r28kcfyirg1s773l4plzr9rilwiadw57asxlf2armqiax8s2gm";

    cargoPatches = [
      # Backport an rtnetlink bump, which resolves a duplicate dependency issue.
      ./0001-Merge-pull-request-2152-from-liubin-fix-2111-update-.patch
    ];
    patchFlags = [ "-p3" ];

    # Fix hardcoded paths.
    postPatch = ''
      substituteInPlace src/rpc.rs \
        --replace /sbin/modprobe ${kmod}/bin/modprobe
      substituteInPlace rustjail/src/container.rs \
        --replace /usr/bin/xargs ${coreutils}/bin/xargs \
        --replace /usr/bin/sleep ${coreutils}/bin/sleep
    '';

    preBuild = ''
      make src/version.rs
    '';

    # Disable tests that try to do things that don't make sense inside the build sandbox.
    checkFlags = [
      # Checks that there's at least one route, but the sandbox is offline by design.
      "--skip netlink::tests::list_routes"
      # Tries to load the `bridge` kernel module, on the assumption that it should always
      # be available, but you (thankfully!) can't modprobe from inside the sandbox.
      "--skip rpc::tests::test_load_kernel_module"
    ];
  };
}
