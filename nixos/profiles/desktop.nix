{ config, lib, pkgs, pkgs-unstable, ... }:

let
  cfg = config.custom.profiles.desktop;
in
{
  imports = [
    ./common/base.nix
  ];

  options.custom.profiles.desktop = {
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
    custom.services.gnome.enable = (cfg.desktopEnvironment == "gnome");
    custom.services.plasma.enable = (cfg.desktopEnvironment == "plasma");
    custom.services.tailscale.enable = cfg.personal;

    environment.systemPackages = (with pkgs-unstable; [
      chromium
    ] ++ lib.optionals cfg.personal [
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
