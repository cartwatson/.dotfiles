{ config, lib, ... }:

let
  cfg = config.pillar.services.oauth2-proxy;
in
{
  options.pillar.services.oauth2-proxy = {
    enable = lib.mkEnableOption "Enable oauth2-proxy";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "example.com";
      description = "Base domain used for proxying";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4180;
      description = "Port for the oauth2-proxy.";
    };

    setup = {
      clientID = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      clientSecretFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
      cookieSecretFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
      authorizedEmailsFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "File of authorized users email's, each on it's own line.";
      };
    };

    proxy = {
      enable = lib.mkEnableOption "Enable proxying oauth2-proxy";
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "auth";
        description = "The subdomain for the reverse proxy.";
      };
      internal = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Should the proxy host this service internally or externally.";
      };
      auth = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "This must stay false. Option is defined only for consistency.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
     assertions = [
      {
        assertion = !cfg.proxy.auth;
        message = "Auth cannot require Auth! Circular dependency error otherwise.";
      }
     ];

     services.oauth2-proxy = {
      enable = true;
      provider = "github";
      reverseProxy = true;
      trustedProxyIP = [ "127.0.0.1" ];
      httpAddress = "http://127.0.0.1:${toString cfg.port}";
      clientID = cfg.setup.clientID;
      clientSecretFile = cfg.setup.clientSecretFile;

      # ref: https://oauth2-proxy.github.io/oauth2-proxy/configuration/overview/
      cookie = {
        # generate cookie secret
        # dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | tr -d -- '\n' | tr -- '+/' '-_' ; echo
        secretFile = cfg.setup.cookieSecretFile;
        domain = ".${cfg.domain}";
      };

      extraConfig = {
        authenticated-emails-file = cfg.setup.authorizedEmailsFile;
      };
    };
  };
}
