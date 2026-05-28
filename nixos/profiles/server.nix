{ config, lib, pkgs, ... }:

let
  cfg = config.custom.profiles.server;
in
{
  options.custom.profiles.server = {
    enable = lib.mkEnableOption "Enable default server config.";
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Primary domain name for server services";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.domainName != "";
        message = "A domain name is required to enable server";
      }
    ];

    sops.secrets = {
      "api_tokens/github_readonly" = {};
      "api_tokens/cloudflare" = {};
      "tailscale/auth_key" = {};
      "glance/location" = {};
    };

    custom = {
      secrets.enable = true;
      services.timezone.tz = "Etc/Zulu";
      services.tailscale = {
        enable = true;
        authKeyFile = "/run/secrets/tailscale/auth_key";
        ssh.enable = true;
        exit-node.enable = true;
      };
      services.ssh = {
        enable = true;
        port = 9999;
      };
      services.caddy = {
        enable = true;
        domain = cfg.domainName;
      };
      services.ddclient = {
        enable = true;
        cloudfareApiKeyPath = "/run/secrets/api_tokens/cloudflare";
        domainName = cfg.domainName;
      };
      services.glance = {
        enable = true;
        port = 8001;
        proxy = {
          enable = true;
          subdomain = "dashboard";
        };
      };
      services.personal-site = {
        enable = true;
        port = 8002;
      };
      services.minecraftServer.enable = true;
    };
  };
}
