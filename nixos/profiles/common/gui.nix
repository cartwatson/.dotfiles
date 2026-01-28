# IMPORTANT: Included pkgs & settings for **ALL GUI** configurations
# import this with display manger (currently only gnome)

{ config, lib, pkgs, pkgs-unstable, ... }:

let
  cfg = config.custom.services;
in
{
  config = lib.mkIf (
    cfg.gnome.enable
    || cfg.plasma.enable
  ) {
    environment.systemPackages = (with pkgs-unstable; [
      chromium
      vscodium
      spotify
      bitwarden-desktop
    ]);

    programs.chromium = {
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # bitwarden
      ];
      extraOpts = {
        "PasswordManagerEnabled" = false;
      };
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };
}
