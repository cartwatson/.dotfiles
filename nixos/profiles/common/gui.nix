# IMPORTANT: Included pkgs & settings for **ALL GUI** configurations

{ config, pkgs, lib, pkgs-unstable, ... }:

{
  imports = [
  ];

  environment.systemPackages = (with pkgs-unstable; [
    vscodium

    chromium
    spotify
    discord
    slack
    bitwarden-desktop

    drawing

    qbittorrent
  ]);

  programs.chromium.extensions = [
    "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
  ];
}
