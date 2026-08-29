{ config, lib, pkgs, ... }:

let
  cfg = config.pillar.profiles.server;
in
{
  options.pillar.profiles.server = {
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

      "oauth2-proxy/client_secret" = { sopsFile = ../secrets/oauth2-proxy.yaml; };
      "oauth2-proxy/cookie_secret" = { sopsFile = ../secrets/oauth2-proxy.yaml; };
      "oauth2-proxy/authorized_emails" = { sopsFile = ../secrets/oauth2-proxy.yaml; };
    };

    pillar = {
      secrets.enable = true;
      services.timezone.tz = "Etc/Zulu";
      services.oauth2-proxy = {
        enable = true;
        domain = cfg.domainName;
        proxy.enable = true;
        setup = {
          clientID = "Ov23liGmeEEYor02mUtZ";
          clientSecretFile = "/run/secrets/oauth2-proxy/client_secret";
          cookieSecretFile = "/run/secrets/oauth2-proxy/cookie_secret";
          authorizedEmailsFile = "/run/secrets/oauth2-proxy/authorized_emails";
        };
      };
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
        cloudflareApiKeyPath = "/run/secrets/api_tokens/cloudflare";
        domainName = cfg.domainName;
      };
      services.glance = {
        enable = true;
        port = 8001;
        proxy = {
          enable = true;
          subdomain = "dashboard";
          auth = true;
        };
      };
      services.personal-site = {
        enable = false; # TODO: FIX: this is broken, needs a diff host
        port = 8002;
      };
      services.minecraftServer.enable = true;
    };

    # auto pull down changes nightly
    system.autoUpgrade = {
      enable = true;
      # Server is in UTC
      # 0300 PST -> 1000 UTC
      # 0400 PST -> 1100 UTC
      dates = "*-*-* 10:00:00";
      flake = "github:cartwatson/.dotfiles?dir=nixos";

      allowReboot = true; # Reboots ONLY if the kernel/boot loader changes
      rebootWindow = {
        lower = "10:00";  # Earliest time a reboot can happen
        upper = "11:00";  # Latest time a reboot can happen
      };
    };
  };
}
