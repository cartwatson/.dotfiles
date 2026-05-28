# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  custom.profiles.server = {
    enable = true;
    domainName = "jjwatson.dev";
  };
  custom.secrets.keyfile = lib.mkForce "/var/lib/custom-sops/keys.txt";
  custom.services.personal-site.enable = lib.mkForce false;
  custom.services.tailscale.ssh.enable = lib.mkForce false;
  custom.services.tailscale.exit-node.enable = lib.mkForce false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11"; # Did you read the comment?
}
