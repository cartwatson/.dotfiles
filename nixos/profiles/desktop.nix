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

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      gnome = { custom.services.gnome.enable = true; };
      plasma = { custom.services.plasma.enable = true; };
    }.${cfg.desktopEnvironment}

    {
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
      };
    }

    # CUSTOM
    {
      services.tailscale.enable = true;
    }
  ]);
}
