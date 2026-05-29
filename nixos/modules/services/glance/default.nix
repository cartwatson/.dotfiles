{ config, lib, pkgs, pkgs-unstable, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.glance;

  configFile = pkgs.writeText "/var/lib/secrets/glance/env"
    ''
      # Theme - HSL Values
      ## Gruvbox - Dark mode - https://github.com/morhetz/gruvbox?tab=readme-ov-file#palette
      ### MISC
      GRUVBOX_BG="195 6 12"
      GRUVBOX_FG="48 86 88"

      ### upper values in color chart
      GRUVBOX_RED_DARK="2 75 46"
      GRUVBOX_GREEN_DARK="60 71 35"
      GRUVBOX_YELLOW_DARK="40 73 49"
      GRUVBOX_BLUE_DARK="183 33 40"
      GRUVBOX_PURPLE_DARK="333 34 54"
      GRUVBOX_AQUA_DARK="122 21 51"
      GRUVBOX_ORANGE_DARK="24 88 45"

      ### bottom values in color chart -- 9-15 + orange
      GRUVBOX_RED="9 96 59"
      GRUVBOX_GREEN="61 66 44"
      GRUVBOX_YELLOW="61 66 44"
      GRUVBOX_BLUE="157 16 58"
      GRUVBOX_PURPLE="344 47 68"
      GRUVBOX_AQUA="104 35 62"
      GRUVBOX_ORANGE="27 96 54"
    '';
in
{
  options.custom.services.glance = {
    enable = lib.mkEnableOption "Enable Glance.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8001;
      description = "Port for the glance server.";
    };
    proxy = {
      enable = lib.mkEnableOption "Enable proxy";
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "glance";
        description = "The subdomain the proxy should use to reverse proxy.";
      };
      internal = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Should the proxy host this service internally or externally.";
      };
      auth = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Should the proxy require auth to access this service.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.glance = {
      enable = true;
      package = pkgs-unstable.glance;
      openFirewall = false;
      environmentFile = configFile;
      settings = {
        theme = {
          background-color    = "\${GRUVBOX_BG}";
          primary-color       = "\${GRUVBOX_FG}";
          positive-color      = "\${GRUVBOX_GREEN}";
          negative-color      = "\${GRUVBOX_RED}";
          contrast-multiplier = 1.3;
        };
        branding = {
          hide-footer = true;
          # logo-url = null;
          # favicon-url = null;
        };
        server = {
          port = cfg.port;
          host = "127.0.0.1";
        };
        pages = [
          (import ./home.nix)
        ];
      };
    };
  };
}
