# IMPORTANT: Included pkgs & settings for **ALL GUI** configurations
# import this with display manger (currently only gnome)

{ config, lib, pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = (with pkgs-unstable; [
    vscodium
    chromium
    spotify
    bitwarden-desktop

    flameshot # TODO: find a way to deterministically config this
  ]);

  programs.chromium.extensions = [
    "nngceckbapebfimnlniiiahkandclblb" # bitwarden
  ];
}
