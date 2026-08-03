{ config, lib, pkgs, pkgs-unstable, ... }:

let
  cfg = config.pillar.profiles.desktop;
in
{
  options.pillar.profiles.desktop = {
    enable = lib.mkEnableOption "Enable default desktop config.";
    personal = lib.mkEnableOption "Include personal packages and services" // { default = true; };
    desktopEnvironment = lib.mkOption {
      type = lib.types.enum [
        "gnome"
        "plasma"
      ];
      default = "gnome";
      description = "Which desktop environment to use";
    };
  };

  config = lib.mkIf cfg.enable {
    pillar.services.gnome.enable = (cfg.desktopEnvironment == "gnome");
    pillar.services.plasma.enable = (cfg.desktopEnvironment == "plasma");
    pillar.services.tailscale.enable = cfg.personal;

    environment.systemPackages = (with pkgs-unstable; [
    ] ++ lib.optionals cfg.personal [
      spotify
    ]);

    programs.chromium = {
      enable = true;
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # bitwarden
      ];
      extraOpts = {
        "PasswordManagerEnabled" = false;
      };
    };

    services.printing.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
