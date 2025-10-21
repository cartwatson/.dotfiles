{ config, lib, pkgs, settings, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.lldap;
in
{
  options.custom.services.lldap = {
    enable = lib.mkEnableOption "Enable lldap.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9001;
      description = "Port for the auth server.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.lldap = {
      enable = true;
      settings = {
        # ldap_port = cfg.port;
        ldap_base_dn = "dc=jjwatson,dc=dev"; # TODO: find way to do this with settings.domainName
        http_port = cfg.port; # expose through caddy
      };
    };
  };
}
