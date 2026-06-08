{ config, lib, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.caddy;

  virtualHost = serviceCfg:
    lib.mkIf serviceCfg.proxy.enable {
      "${serviceCfg.proxy.subdomain}.${cfg.domain}".extraConfig =
        "reverse_proxy :${toString serviceCfg.port}";
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
        (lib.mkIf baseCfg.personal-site.enable {"cartwatson.com".extraConfig = '' reverse_proxy :${toString baseCfg.personal-site.port} '';})
        ({"caddy.${cfg.domain}".extraConfig = '' respond "Caddy Up V2!" '';}) # test caddy for glance dash
      ];
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
