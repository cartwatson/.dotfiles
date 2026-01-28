{ config, lib, pkgs, pkgs-unstable, settings, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../hardware/nvidia.nix
  ];

  custom = {
    services.gnome.enable = true;
    services.timezone.automatic = true;
    services.tailscale.enable = true;
    services.gaming = {
      enable = true;
      minecraft = true;
    };
  };

  environment.systemPackages = (with pkgs; [
    firefox
  ]);

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  # Enable touchpad support (enabled by default in most desktopManager).
  services.libinput.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
