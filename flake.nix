{
  description = "NixOS Mobile for OnePlus 6 (enchilada)";

  ############################################
  # Input Dependencies
  ############################################
  inputs = {
    # Main NixOS package collection (unstable for latest mobile support)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Mobile-NixOS repository - provides mobile-specific modules and device support
    mobile-nixos = {
      url = "github:mobile-nixos/mobile-nixos";
      flake = false; # We import it directly, not as a flake
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  ############################################
  # Flake Outputs
  ############################################
  outputs = inputs @ {
    self,
    nixpkgs,
    mobile-nixos,
    ...
  }: let
    system = "aarch64-linux";

    tacos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        inputs.vscode-server.nixosModules.default
        (import "${mobile-nixos}/lib/configuration.nix" {device = "oneplus-fajita";})
        ./configuration.nix
      ];
    };

    mobile_outputs = tacos.config.mobile.outputs;
  in {
    # Aliases to the generated outputs of mobile-nixos
    images = {
      inherit (mobile_outputs.android) android-fastboot-images android-bootimg;
      inherit (mobile_outputs.generatedFilesystems) rootfs;
    };

    nixosConfigurations = {inherit tacos;};
  };
}
