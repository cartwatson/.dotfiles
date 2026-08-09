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
      chromium
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

    programs.firefox = {
      enable = true;

      policies = {
        # misc
        AppAutoUpdate                 = false;
        BackgroundAppUpdate           = false;
        OfferToSaveLogins             = false;
        DontCheckDefaultBrowser       = true;
        DisablePocket                 = true;
        DisableMasterPasswordCreation = true;
        DisableProfileImport          = true;
        DisableProfileRefresh         = true;

        # Extensions
        # wiki: https://wiki.nixos.org/wiki/Firefox#Advanced
        # ref:  https://mozilla.github.io/policy-templates/#extensionsettings
        ExtensionSettings = let
          moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        in {
          # "*".installation_mode = "blocked"; # only listed extensions can be installed

          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url       = moz "bitwarden-password-manager";
            installation_mode = "normal_installed";
            updates_disabled  = false; # non-deterministic but good for bitwarden
          };

          # "uBlock0@raymondhill.net" = {
          #   install_url       = moz "ublock-origin";
          #   installation_mode = "force_installed";
          #   updates_disabled  = true;
          # };
        };
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
