{ config, lib, pkgs, pkgs-unstable, settings, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.caddy;

  virtualHost = serviceCfg:
    lib.mkIf serviceCfg.proxy.enable {
      "${serviceCfg.proxy.subdomain}${if serviceCfg.proxy.internal then "." + baseCfg.tailscale.proxy.subdomain else ""}.${settings.domainName}".extraConfig =
      if serviceCfg.proxy.auth then
        ''
          forward_auth :${config.custom.services.authelia.port} {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
          }

          reverse_proxy :${toString serviceCfg.port}
        ''
      else
        ''
          reverse_proxy :${toString serviceCfg.port}
        ''
      ;
    };
in
{
  options.custom.services.caddy = {
    enable = lib.mkEnableOption "Enable Caddy.";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "example.com";
      description = "Base domain used for proxying";
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts = lib.mkMerge [
        # TODO: pull enabled services from config.custom
        (virtualHost baseCfg.glance)
        (virtualHost baseCfg.tailscale)
        ({"caddy.${cfg.domain}".extraConfig = '' respond "Caddy Up!" '';}) # test caddy for glance dash
      ];
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
