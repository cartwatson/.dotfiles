{ config, lib, pkgs, pkgs-unstable, ... }:

let
  cfg = config.custom.profiles.desktop;
in
{
  options.custom.profiles.desktop = {
    enable = lib.mkEnableOption "Enable default desktop config.";
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
    custom.services.gnome.enable = (cfg.desktopEnvironment == "gnome");
    custom.services.plasma.enable = (cfg.desktopEnvironment == "plasma");
    custom.services.tailscale.enable = true;

    environment.systemPackages = (with pkgs-unstable; [
      chromium
      spotify
    ]);

    programs.chromium = {
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
