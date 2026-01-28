{ config, lib, pkgs, pkgs-unstable, settings, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    secrets.enable = true;
    services.gnome = {
      enable = true;
      numWorkspaces = 9;
    };
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
