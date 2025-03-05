# IMPORTANT: Included pkgs & settings for **ALL GUI** configurations

{ config, pkgs, lib, self, ... }:

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
