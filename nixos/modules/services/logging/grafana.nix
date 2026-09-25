{ config, lib, pkgs, ... }:
let
  baseCfg = config.pillar.services;
  cfg = baseCfg.grafana;
in
{
  options.pillar.services.grafana = {
    enable = lib.mkEnableOption "Enable Grafana.";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "example.com";
      description = "Base domain used for proxying";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port for the grafana server.";
    };

    security = {
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
          domain = "${cfg.proxy.subdomain}.${cfg.domain}";
          root_url = "https://${cfg.proxy.subdomain}.${cfg.domain}/";
        };

# ----- TEST -------------------------------------------------------------------
        # Turn off Grafana's own credential-based login entirely.
        auth = {
          disable_login_form = true; # no username/password form
          disable_signout_menu = true; # signout is handled by oauth2-proxy's /oauth2/sign_out
        };
        # Trust identity forwarded by oauth2-proxy instead.
        # https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/auth-proxy/
        "auth.proxy" = {
          enabled = true;
          header_name = "X-Auth-Request-User";
          header_property = "username";
          auto_sign_up = true; # create Grafana users on first login
          sync_ttl = 60; # minutes between re-syncing user info from headers
          whitelist = "127.0.0.1";
          headers = "Email:X-Auth-Request-Email Name:X-Auth-Request-Preferred-Username";
        };

        # Optional: give every proxy-authenticated user Editor by default
        # instead of Viewer, or manage roles via org mapping elsewhere.
        users.auto_assign_org_role = "Viewer";
# ----- TEST -------------------------------------------------------------------

        security = {
          secret_key = "$__file{${cfg.security.secret_key}}";
        };

        # Prevents Grafana from phoning home
        analytics.reporting_enabled = false;
      };
    };
  };
}
