{ config, lib, pkgs, pkgs-unstable, settings, ... }:

let
  virtualHost = cfg:
    lib.mkIf cfg.enable {
      "${cfg.subdomain}.${config.custom.services.caddy.domain}".extraConfig = ''
        reverse_proxy :${toString cfg.port}
      '';
    };
in
{
  options.custom.services.caddy = {
    enable = lib.mkEnableOption "Enable Caddy.";
    domain = lib.mkOption {
      type = lib.types.str;
      default = settings.domainName;
      description = "Base domain used for subdomains of services.";
    };
  };

  config = lib.mkIf config.custom.services.caddy.enable {
    services.caddy = {
      enable = true;
      virtualHosts = lib.mkMerge [
        # TODO: pull enabled services from config.custom
        # this could cause issuse wtih multiple minecraft servers though...
        (virtualHost config.custom.services.glance)
        (virtualHost config.custom.services.tailscale)
      ];
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}

