# Minimal configuration for OnePlus 6 (enchilada) NixOS Mobile
# Focus on essentials: SSH, wireless, and basic tools
{
  self,
  config,
  lib,
  pkgs,
  ...
}: let
  vivaldi = pkgs.vivaldi.override {commandLineArgs = ["--ozone-platform-hint=auto"];};
  kiosk_user = "kiosk";
in {
  # Allow unfree packages (needed for OnePlus firmware)
  nixpkgs.config.allowUnfree = true;

  # Cross-compilation test
  # nixpkgs = {
  #   buildPlatform.system = "x86_64-linux";
  #   hostPlatform.system = "aarch64-linux";
  # };

  # Enable SSH server (essential for mobile device access)
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes"; # For initial setup
  services.openssh.settings.PasswordAuthentication = true; # For initial setup

  # Enable audio
  # PipeWire is enabled by default, but the audio is very quiet with it
  services.pipewire.enable = lib.mkForce false;
  # Make sure to select "Speakers Output" as the output device in the settings
  services.pulseaudio.enable = true;

  # Set root password for SSH access
  users.users.root.password = "wow";

  # Enable GNOME Desktop Environment
  # services.xserver.enable = true;
  # services.desktopManager.gnome.enable = true;
  # services.displayManager.gdm.enable = true;

  # Enable GNOME Keyring for password management
  # services.gnome.gnome-keyring.enable = true;

  # Enable dconf for GNOME settings
  # programs.dconf.enable = true;

  # Remove unwanted GNOME applications
  /*
     environment.gnome.excludePackages = with pkgs; [
    baobab # disk usage analyzer
    cheese # photo booth
    eog # image viewer
    epiphany # web browser
    simple-scan # document scanner
    totem # video player
    yelp # help viewer
    evince # document viewer
    file-roller # archive manager
    geary # email client
    seahorse # password manager
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-clocks
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-screenshot
    gnome-system-monitor
    gnome-weather
    gnome-disk-utility
    pkgs.gnome-connections
  ];
  */

  # Minimal essential packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    lazygit
    asciiquarium
    kitty

    btop
    nix-output-monitor

    # Kernel build
    python3
  ];

  # Disable terminal login
  # services.getty.loginProgram = "${pkgs.coreutils}/bin/true";
  # RAM can be compressed instead of swapping using `zramSwap.enable = true;`

  networking = {
    hostName = "tacos";
    useNetworkd = true;
    # NetworkManager is uncompatible with `networking.wireless`
    # networkmanager = {
    #   enable = true;
    #   # Use the device's permanent MAC address
    #   wifi.macAddress = "permanent";
    # };

    wireless = {
      enable = true;

      networks = {
        "test".psk = "@@@@@@@@";
      };

      extraConfig = ''
        country=FR
      '';
    };

    # The device's physical mac cannot be read for some reason so the ath driver
    # generates a random one each boot; make it a fixed one instead so we can
    # match our router's DHCP rules and get a fixed ip
    interfaces."wlan0".macAddress = "64:a2:f9:f3:c1:f2";
  };

  # Make the wifi MAC address not random
  # systemd.network.links."wireless-config" = {
  #   matchConfig.Name = "wlan0";
  #   # linkConfig.MACAddressPolicy = "persistent";
  #   linkConfig = {
  #     MACAddressPolicy = "none";
  #     # Extracted using:
  #     ## ```
  #     ## mkdir -p /mnt
  #     ## mount /dev/disk/by-partlabel/persist /mnt
  #     ## grep -Po '^Intf0MacAddress=\K.*' /mnt/wlan_mac.bin
  #     ## umount /mnt
  #     ## ```
  #     MACAddress = "64:a2:f9:f3:c1:f2";
  #   };
  # };

  # Wait for network during boot
  systemd.network.wait-online.enable = true;

  # Kiosk user
  users.users."${kiosk_user}".isNormalUser = true;

  services = {
    cage = {
      enable = true;
      user = kiosk_user;
      program = "${lib.getExe vivaldi} --new-window --kiosk --app='https://home.hugooo.dev?kiosk'";
    };

    vscode-server = {
      enable = true;
      enableFHS = true;
      extraRuntimeDependencies = with pkgs; [
        # Classic tools
        git
        # Nix
        nixd
        nil
        alejandra
        # Other required
        zlib
        openssl.dev
        pkg-config
      ];
    };
  };

  # Weird stuff
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="FR"
  '';

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Customize the kernel with our own patches because why not
  imports = [./kernel];

  # mobile.boot.stage-1.kernel.modular = true;
  # self.images = {
  #   inherit
  #     (config.mobile.outputs.android)
  #     android-bootimg
  #     /*
  #     rootfs
  #     */
  #     ;
  # };

  #   # TODO: try with newer kernel:
  #   /*
  #      src = lib.fetchFromGitLab {
  #     owner = "sdm845-mainline";
  #     repo = "linux";
  #     rev = "v6.15";
  #     ##hash = "sha256-XUYv8tOk0vsG11w8UtBKizlBZ03cbQ2QRGyZEK0ECGU=";
  #   };
  #   */
  # };

  # mobile.boot.boot-control.enable = true;
  # TODO: make mac not random for static leases to work
  # TODO: "Warning: do not know how to make this configuration bootable; please enable a boot loader."

  # Fix shutdown wifi driver crashing the kernel: https://gitlab.com/sdm845-mainline/linux/-/issues/52

  system.stateVersion = "25.11";
}
