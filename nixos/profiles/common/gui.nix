# IMPORTANT: Included pkgs & settings for **ALL GUI** configurations
# import this with display manger (currently only gnome)

{ config, lib, pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = (with pkgs-unstable; [
    chromium
    vscodium
    spotify
    bitwarden-desktop
  ]);

  programs.chromium.extensions = [
    "nngceckbapebfimnlniiiahkandclblb" # bitwarden
  ];
}
