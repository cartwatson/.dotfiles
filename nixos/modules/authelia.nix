{ config, lib, pkgs, settings, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.authelia;
in
{
  options.custom.services.authelia = {
    enable = lib.mkEnableOption "Enable Authelia.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9091;
      description = "Port for the auth server.";
    };
    proxy = {
      enable = lib.mkEnableOption "Enable proxy";
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "auth";
        description = "The subdomain the proxy should use to reverse proxy.";
      };
#-HOW TO WORK AROUND THIS-------------------------------------------------------
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
#-------------------------------------------------------------------------------
    };
  };

  config = lib.mkIf cfg.enable {
    services.authelia.instances.jjwatson = {
      enable = true;
      settings = {
        theme = "auto";
        ## The following commented line is for configuring the Authelia URL in the proxy. We strongly suggest
        ## this is configured in the Session Cookies section of the Authelia configuration.
        # uri /api/authz/forward-auth?authelia_url=https://auth.example.com/

        # telemetry.metrics = {
        #   enabled = true;
        #   addrss = "";
        # };
      };
    };
  };
}
