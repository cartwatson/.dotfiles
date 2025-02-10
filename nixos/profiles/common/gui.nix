# IMPORTANT: Included pkgs & settings for **ALL GUI** configurations

{ config, pkgs, lib, self, ... }:

{
  imports = [
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    vscodium

    firefox
    spotify
    discord
    slack

    kdePackages.kolourpaint
  ]);
}
