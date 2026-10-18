{ config, pkgs, lib, ... }:

let
  cfg = config.pillar.profiles.server;
  ports = {
    grafana    = 3000;
    openttd    = 3979; # unused
    oauth2     = 4180;
    mc-kuiper  = 5003;
    actual     = 5006;
    glance     = 8001;
    blog       = 8002;
    p-node     = 9001; # prometheus node
    prometheus = 9090;
  };

  port_collision_check = ports_dict:
    (ports: ports == lib.lists.unique ports) (builtins.attrValues ports_dict);

  # secrets management
  oauth2-proxy = {
    sopsFile = ../secrets/oauth2-proxy.yaml;
    owner = config.users.users.oauth2-proxy.name;
    group = config.users.users.oauth2-proxy.group;
  };
  grafana = {
    sopsFile = ../secrets/grafana.yaml;
    owner = config.users.users.grafana.name;
    group = config.users.users.grafana.group;
  };
  restic = {
    sopsFile = ../secrets/backups.yaml;
    owner = config.users.users.restic.name;
    group = config.users.users.restic.group;
  };

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
      {
        assertion = port_collision_check ports;
        message = "Server ports must not collide";
      }
    ];

    sops.secrets = {
      "api_tokens/github_readonly" = {};
      "api_tokens/cloudflare" = {};
      "tailscale/auth_key" = {};
      "glance/location" = {};

      "oauth2-proxy/client_secret" = oauth2-proxy;
      "oauth2-proxy/cookie_secret" = oauth2-proxy;
      "oauth2-proxy/authorized_emails" =  oauth2-proxy;
      "grafana/secret_key" = grafana;
      "restic/blackblaze/server-url" = restic;
      "restic/blackblaze/keyId" = restic;
      "restic/restic-password" = restic;
    };
    sops.templates."backblaze-restic.env" = {
      mode = "0400";
      content = ''
        RESTIC_REPOSITORY=${config.sops.placeholder."backblaze/server-url"}
        AWS_DEFAULT_REGION=${config.sops.placeholder."backblaze/access-region"}
        AWS_ACCESS_KEY_ID=${config.sops.placeholder."backblaze/key-id"}
        AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."backblaze/application-key"}
        RESTIC_PASSWORD=${config.sops.placeholder."backblaze/restic-password"}
      '';
    };

    pillar = {
      secrets.enable = true;
      services.actual = {
        enable = true;
        port = ports.actual;
        proxy = {
          enable = true;
          subdomain = "budget";
          auth = true;
        };
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
        port = ports.glance;
        proxy = {
          enable = true;
          subdomain = "dashboard";
          auth = true;
        };
      };
      services.grafana = {
        enable = true;
        domain = cfg.domainName;
        port = ports.grafana;
        security = {
          secret_key = "/run/secrets/grafana/secret_key";
        };
        proxy = {
          enable = true;
          subdomain = "logs";
          auth = true;
        };
      };
      services.minecraftServer = {
        enable = true;
        servers.kuiper = import ../modules/services/minecraft/kuiper.nix { inherit pkgs; } // { port = ports.mc-kuiper; };
      };
      services.oauth2-proxy = {
        enable = true;
        domain = cfg.domainName;
        proxy.enable = true;
        port = ports.oauth2;
        setup = {
          clientID = "Ov23liGmeEEYor02mUtZ";
          clientSecretFile = "/run/secrets/oauth2-proxy/client_secret";
          cookieSecretFile = "/run/secrets/oauth2-proxy/cookie_secret";
          authorizedEmailsFile = "/run/secrets/oauth2-proxy/authorized_emails";
        };
      };
      services.personal-site = {
        enable = false; # TODO: FIX: this is broken, needs a diff host
        port = cfg.blog;
      };
      services.prometheus = {
        enable = true;
        port = ports.prometheus;
        node = {
          enable = true;
          port = ports.p-node;
        };
      };
      services.restic = {
        enable = true;
        backupConnections = {
          backblaze.environmentFile = config.sops.templates."backblaze-restic.env".path;
        };
      };
      services.tailscale = {
        enable = true;
        authKeyFile = "/run/secrets/tailscale/auth_key";
        ssh.enable = true;
        exit-node.enable = true;
      };
      services.timezone.tz = "Etc/Zulu";
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
