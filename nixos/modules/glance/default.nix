{ config, lib, pkgs, pkgs-unstable, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.glance;
in
{
  # NOTE: needed until 25.11 for `environmnetFile` option
  disabledModules = ["services/web-apps/glance.nix"];
  imports = ["${pkgs-unstable.path}/nixos/modules/services/web-apps/glance.nix"];

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
      environmentFile = "/var/lib/secrets/glance/env";
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
          (import ./nova.nix)
        ];
      };
    };
  };
}
