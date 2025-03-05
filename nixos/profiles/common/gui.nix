# IMPORTANT: Included pkgs & settings for **ALL GUI** configurations

{ pkgs, lib, ... }:

{
  imports = [
  ];

  environment.systemPackages = (with pkgs; [
    vscodium

    chromium
    spotify
    discord
    slack

    kdePackages.kolourpaint
  ]);
}
