# IMPORTANT: Included pkgs & settings for **ALL GUI** configurations

{ config, lib, pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = (with pkgs-unstable; [
    vscodium
    chromium
    spotify
    bitwarden-desktop
  ]);

  programs.chromium.extensions = [
    "nngceckbapebfimnlniiiahkandclblb" # bitwarden
  ];
}
