{
  mobile-nixos,
  fetchFromGitLab,
  fetchpatch,
  pkgs,
  ...
}:
mobile-nixos.kernel-builder {
  # version = "6.4.0";
  version = "6.14.0-rc1";
  configfile = ./config.aarch64;

  src = fetchFromGitLab {
    owner = "sdm845-mainline";
    repo = "linux";
    # rev = "sdm845-6.4-r1";
    rev = "sdm845-6.13.0-r3";
    # hash = "sha256-XUYv8tOk0vsG11w8UtBKizlBZ03cbQ2QRGyZEK0ECGU=";
    hash = "sha256-bnaZtLZPyvkI33ZkgicNWBIgH4LMuSz8H91aapQMXX4=";
  };

  # It seems the newer kernel requires `python3`
  nativeBuildInputs = with pkgs; [python3];

  patches = [
    # ASoC: codecs: tas2559: Fix build
    /*
       (fetchpatch {
      url = "https://github.com/samueldr/linux/commit/d1b59edd94153ac153043fb038ccc4e6c1384009.patch";
      sha256 = "sha256-zu1m+WNHPoXv3VnbW16R9SwKQzMYnwYEUdp35kUSKoE=";
    })
    */

    ./custom-patches/override-ath-reg-country.patch

    ./custom-patches/test.patch
  ];

  isModular = false;
  isCompressed = "gz";
}
