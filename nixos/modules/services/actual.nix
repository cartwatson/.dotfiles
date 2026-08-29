{ config, lib, pkgs, ... }:

let
  baseCfg = config.pillar.services;
  cfg = baseCfg.actual;
in
{
  options.pillar.services.actual = {
    enable = lib.mkEnableOption "Enable Actual.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5006;
      description = "Port for Actual.";
    };
    proxy = {
      enable = lib.mkEnableOption "Enable proxy";
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "actual";
        description = "The subdomain the proxy should use to reverse proxy.";
      };
      internal = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Should the proxy host this service internally or externally.";
      };
      auth = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Should the proxy require auth to access this service.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.actual = {
      enable = true;
      openFirewall = false;
      settings = {
        port = cfg.port;
        # Restrict allowed methods or disable password enforcement if possible,
        # and tell Actual to trust headers or change login behavior:
        loginMethod = "header";
        allowedLoginMethods = [ "header" ];
      };
    };
  };
}
