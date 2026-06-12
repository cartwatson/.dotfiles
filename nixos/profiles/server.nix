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
        cloudflareApiKeyPath = "/run/secrets/api_tokens/cloudflare";
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
        enable = false; # TODO: FIX: this is broken, needs a diff host
        port = 8002;
      };
      services.minecraftServer.enable = true;
    };

    # auto pull down changes nightly
    system.autoUpgrade = {
      enable = true;
      dates = "*-*-* 08:00:00"; # Server is in UTC, 0000 PST
      flake = "github:cartwatson/.dotfiles?dir=nixos";

      allowReboot = true; # Reboots ONLY if the kernel/boot loader changes
      rebootWindow = {
        lower = "08:00";  # Earliest time a reboot can happen (UTC)
        upper = "09:00";  # Latest time a reboot can happen (UTC)
      };
    };
  };
}
