{ config, pkgs, lib, ... }:

let
  cfg = config.pillar.profiles.server;
  secretCfg = config.sops.secrets;
  ports = {
    grafana     = 3000;
    openttd     = 3979; # unused
    oauth2      = 4180;
    mc-amalthea = 5003;
    actual      = 5006;
    glance      = 8001;
    blog        = 8002;
    p-node      = 9001; # prometheus node
    prometheus  = 9090;
  };

  port_collision_check = ports_dict:
    (ports: ports == lib.lists.unique ports) (builtins.attrValues ports_dict);

  # secrets management
  secretManager = user: sopsFile: {
    inherit sopsFile;
    owner = config.users.users."${user}".name; # group is auto assigned from user
  };

  oauth2-proxy-secrets = secretManager "oauth2-proxy" ../secrets/oauth2-proxy.yaml;
  grafana-secrets = secretManager "grafana" ../secrets/grafana.yaml;
  restic-secrets = secretManager "restic" ../secrets/backups.yaml;
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
        message = "pillar.profiles.server.domainName: A domain name is required to enable server";
      }
      {
        assertion = port_collision_check ports;
        message = "pillar.profiles.server: Server ports must not collide";
      }
    ];

    sops.secrets = {
      "api_tokens/github_readonly" = {};
      "api_tokens/cloudflare" = {};
      "tailscale/auth_key" = {};
      "glance/location" = {};

      "oauth2-proxy/client_secret" = oauth2-proxy-secrets;
      "oauth2-proxy/cookie_secret" = oauth2-proxy-secrets;
      "oauth2-proxy/authorized_emails" = oauth2-proxy-secrets;
      "grafana/secret_key" = grafana-secrets;

      "backblaze/server-url" = restic-secrets;
      "backblaze/access-region" = restic-secrets;
      "backblaze/key-id" = restic-secrets;
      "backblaze/application-key" = restic-secrets;
      "backblaze/restic-password" = restic-secrets;
    };
    sops.templates."backblaze-restic.env" = {
      mode = "0400";
      content = ''
        AWS_DEFAULT_REGION=${config.sops.placeholder."backblaze/access-region"}
        AWS_ACCESS_KEY_ID=${config.sops.placeholder."backblaze/key-id"}
        AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."backblaze/application-key"}
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
        inherit (cfg) domainName;
        cloudflareApiKeyPath = secretCfg."api_tokens/cloudflare".path;
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
        security.secret_key = secretCfg."grafana/secret_key".path;
        port = ports.grafana;
        proxy = {
          enable = true;
          subdomain = "logs";
          auth = true;
        };
      };
      services.minecraftServer = {
        enable = true;
        servers.amalthea = import ../modules/services/minecraft/amalthea.nix { inherit pkgs; port = ports.mc-amalthea; };
      };
      services.oauth2-proxy = {
        enable = true;
        domain = cfg.domainName;
        proxy.enable = true;
        port = ports.oauth2;
        setup = {
          clientID = "Ov23liGmeEEYor02mUtZ";
          clientSecretFile = secretCfg."oauth2-proxy/client_secret".path;
          cookieSecretFile = secretCfg."oauth2-proxy/cookie_secret".path;
          authorizedEmailsFile = secretCfg."oauth2-proxy/authorized_emails".path;
        };
      };
      services.personal-site = {
        enable = false; # TODO: FIX: this is broken, needs a diff host
        port = ports.blog;
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
          backblaze = {
            serverURL = secretCfg."backblaze/server-url".path;
            passwordFile = secretCfg."backblaze/restic-password".path;
            environmentFile = config.sops.templates."backblaze-restic.env".path;
          };
        };
      };
      services.tailscale = {
        enable = true;
        authKeyFile = secretCfg."tailscale/auth_key".path;
        ssh.enable = true;
        exit-node.enable = true;
      };
      services.timezone.tz = "Etc/Zulu";
      services.autoUpdate = {
        enable = true;
        updateTime = "10:00"; # 1000 UTC -> 0300 PST
      };
    };
  };
}
