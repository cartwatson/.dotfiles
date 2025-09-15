{ config, lib, pkgs, pkgs-unstable, settings, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.caddy;

  externalVirtualHost = serviceCfg:
    lib.mkIf serviceCfg.enable {
      "${serviceCfg.subdomain}.${cfg.domain}".extraConfig = ''
        reverse_proxy :${toString serviceCfg.port}
      '';
    };

  internalVirtualHost = serviceCfg:
    lib.mkIf serviceCfg.enable {
      "${serviceCfg.subdomain}.${config.custom.services.tailscale.subdomain}.${cfg.domain}".extraConfig = ''
        reverse_proxy localhost:${toString serviceCfg.port}
      '';
    };
in
{
  options.custom.services.caddy = {
    enable = lib.mkEnableOption "Enable Caddy.";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "example.com";
      description = "Base domain used for subdomains of services.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts = lib.mkMerge [
        # TODO: pull enabled services from config.custom
        # this could cause issuse wtih multiple minecraft servers though...
        (externalVirtualHost baseCfg.glance)
        (externalVirtualHost baseCfg.tailscale)
      ];
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}

