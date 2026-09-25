{ config, lib, pkgs, ... }:
let
  baseCfg = config.pillar.services;
  cfg = baseCfg.grafana;
in
{
  options.pillar.services.grafana = {
    enable = lib.mkEnableOption "Enable Grafana.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port for the grafana server.";
    };

    security = {
      # TODO: necessary wiring for oauth2-proxy shenanigans
      secret_key = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "";
      };
    };

    proxy = {
      enable = lib.mkEnableOption "Enable proxy";
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "grafana";
        description = "The subdomain the proxy should use to reverse proxy.";
      };
      auth = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Should the proxy require auth to access this service.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = cfg.port;
          enforce_domain = true;
          enable_gzip = true;
          domain = "${cfg.proxy.subdomain}.jjwatson.dev"; # FIX: hardcoded domain
        };

        # TODO: wire in to oauth2-proxy auth instead of grafana auth
        security = {
          secret_key = "$__file{${cfg.security.secret_key}}";
        };

        # Prevents Grafana from phoning home
        analytics.reporting_enabled = false;
      };
    };
  };
}
