{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  mobile.boot.stage-1.kernel.package = lib.mkForce (pkgs.callPackage ./package.nix {});
  # Some options were removed in newer (> 6.14) kernel versions
  mobile.kernel.structuredConfig = let
    inherit (lib) mkForce;
  in [
    (helpers:
      with helpers; {
        IP_NF_RAW = mkForce no;
        IP6_NF_RAW = mkForce no;
      })
  ];
}
