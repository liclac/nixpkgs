{ pname, version, src, meta, rustPlatform, kmod, coreutils }:
rustPlatform.buildRustPackage {
  pname = "${pname}-agent";
  inherit version src;
  sourceRoot = "source/src/agent";
  cargoSha256 = "07r28kcfyirg1s773l4plzr9rilwiadw57asxlf2armqiax8s2gm";

  patches = [
    # Backport an rtnetlink bump, which resolves a duplicate dependency issue.
    ./0001-agent-backport-netlink-bump-fix-cargo-vendor.patch
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

  meta = meta // {
    description = "kata-containers host agent";
  };
}
