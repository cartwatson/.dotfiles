{ config, lib, pkgs, pkgs-unstable, settings, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/common/gui.nix
  ];

  custom = {
    services.gnome.enable = true;
    services.docker.enable = true;
    services.tailscale.enable = true;
    services.gaming = {
      enable = true;
      minecraft = true;
      sunshine = true;
    };
  };

  environment.systemPackages = (with pkgs; [
    golden-cheetah-bin
  ]);

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # services.pulseaudio.enable = false; # doesn't work on stable, works on unstable 25.05
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
