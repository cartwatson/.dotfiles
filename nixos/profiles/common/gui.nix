# IMPORTANT: Included pkgs & settings for **ALL GUI** configurations

{ config, pkgs, lib, ... }:

{
  imports = [
  ];

  environment.systemPackages = (with pkgs; [
    vscodium

    chromium
    spotify
    discord
    slack
    bitwarden-desktop

    drawing
  ]);
}
