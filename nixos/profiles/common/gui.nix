# IMPORTANT: Included pkgs & settings for **ALL GUI** configurations

{ pkgs-unstable, ... }:

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

    drawing                            # MS Paint alternative
  ]);

  programs.chromium.extensions = [
    "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
  ];
}
