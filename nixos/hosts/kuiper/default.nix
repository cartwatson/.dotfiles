# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  pillar.profiles.server = {
    enable = true;
    domainName = "jjwatson.dev";
  };
  pillar.secrets.keyFile = lib.mkForce "/var/lib/custom-sops/keys.txt";
  pillar.services.personal-site.enable = lib.mkForce false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11"; # Did you read the comment?
}
