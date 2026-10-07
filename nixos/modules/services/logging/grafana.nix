{ config, lib, ... }:
let
  baseCfg = config.pillar.services;
  cfg = baseCfg.grafana;

  localSource = lib.optional baseCfg.prometheus.enable {
    type = "prometheus";
    name = "local-prometheus";
    url = "http://localhost:${toString baseCfg.prometheus.port}";
  };
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

    sources = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "Additional data sources, local source is always configured.";
      example = [
          {
            type = "prometheus";
            name = "remote-prometheus-1"; # arbitrary
            url = "http://10.0.0.5:9090";
          }
      ];
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
    assertions = [
      {
        assertion = cfg.security.secret_key != null;
        message = "Grafana requires a secret key.";
      }
      { # NOTE: `or false` removes the need to have the caddy module available
        assertion = baseCfg.caddy.enable or false -> baseCfg.caddy.domain == cfg.domain;
        message = "If Caddy is enabled, the domain for Caddy and Grafana must be the same.";
      }
    ];

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

        security = {
          secret_key = "$__file{${cfg.security.secret_key}}";
        };

        # Prevents Grafana from phoning home
        analytics.reporting_enabled = false;

        # ----- AUTH -----------------------------------------------------------
        # Turn off Grafana's own credential-based login
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

        users.auto_assign_org_role = "Admin"; # TODO: role based security eventually
        # ----- AUTH -----------------------------------------------------------
      };

      provision = {
        enable = true;
        dashboards.settings.providers = [{
          name = "pillar";
          options.path = ./grafana-dashboards;
        }];

        datasources.settings.datasources = localSource ++ cfg.sources;
      };
    };
  };
}
