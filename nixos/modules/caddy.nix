{ config, lib, pkgs, pkgs-unstable, ... }:

let
  virtualHost = cfg:
    lib.mkIf cfg.enable {
      "${cfg.subdomain}.${config.custom.services.caddy.domain}".extraConfig = ''
        reverse_proxy :${toString cfg.port} {
          header_down X-Real-IP {http.request.remote}
          header_down X-Forwarded-For {http.request.remote}
        }
      '';
    };
in
{
  options.custom.services.caddy = {
    enable = lib.mkEnableOption "Enable Caddy.";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "example.org";
      description = "Base domain used for subdomains of services.";
    };
  };

  config = lib.mkIf config.custom.services.caddy.enable {
    services.caddy = {
      enable = true;
      virtualHosts = lib.mkMerge [
        (virtualHost config.custom.services.glance)
        # (virtualHost config.custom.services.glance)
      ];
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}

