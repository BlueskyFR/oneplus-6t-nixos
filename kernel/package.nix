{
  mobile-nixos,
  fetchFromGitLab,
  fetchpatch,
  pkgs,
  ...
}:
mobile-nixos.kernel-builder {
  version = "6.18.2";
  configfile = ./config.aarch64;

  src = fetchFromGitLab {
    owner = "sdm845-mainline";
    repo = "linux";
    # rev = "sdm845-6.18.2-r0";
    rev = "80db03d89b4f7ad569e8dfa29dab5a1ddada6ac2";
    hash = "sha256-cENd63lZjsQMNNXXwldz4iWqtEcgycc9doS0ZE0baaY=";
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
