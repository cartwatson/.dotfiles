{ config, pkgs, lib, ... }:

let
  baseCfg = config.pillar.services;
  cfg = baseCfg.restic;
  data = config.pillar.data;
in
{
  options.pillar.services.restic = {
    enable = lib.mkEnableOption "Restic.";
    server = {
      enable = lib.mkEnableOption "Restic's server.";
      htpasswd-file = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port for the local restic server.";
      };
      proxy = {
        enable = lib.mkEnableOption "reverse proxy for selected service";
        auth = lib.mkEnableOption "auth from the reverse proxy to access this service.";
        subdomain = lib.mkOption {
          type = lib.types.str;
          default = "restic";
          description = "The subdomain the proxy should use to reverse proxy.";
        };
      };
    };
    backupConnections = lib.mkOption {
      default = { };
      description = "Servers to connect to for backups";
      type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
        options = {
          serverURL = lib.mkOption {
            type = lib.types.path;
            description = "Path to secret containing serverURL";
          };
          passwordFile = lib.mkOption {
            type = lib.types.path;
            description = "Path to secret containing server password";
          };
          environmentFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to secret containing server password";
          };
          backupPaths = lib.mkOption {
            type = lib.types.listOf lib.types.path;
            default = [ ];
            description = "paths to backup by default";
          };
        };
      }));
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.server.enable -> cfg.server.htpasswd-file != null;
        message = "pillar.services.restic.server: htpasswd-file is required (rest-server won't start without auth configured).";
      }
      {
        assertion = !cfg.server.proxy.auth;
        message = "pillar.services.restic.server.proxy.auth: Auth must not be enabled.";
      }
      {
        assertion = cfg.server.enable -> cfg.server.proxy.enable;
        message = "pillar.services.restic.server: Proxy must be enabled for security reasons!";
      }
    ];

    # run restic as user instead of as root
    users = {
      groups.restic = { };
      users.restic = {
        group = "restic";
        isSystemUser = true;
      };
    };

    # create security wrapper to use the above user/group
    security.wrappers.restic = {
      source = lib.getExe pkgs.restic;
      owner = "restic";
      group = "restic";
      permissions = "500";
      capabilities = "cap_dac_read_search+ep";
    };

    pillar.data.forwardedServices.restic = lib.mkIf cfg.server.enable {
      port = cfg.server.port;
      proxy = cfg.server.proxy;
    };

    services.restic = {
      server = lib.mkIf cfg.server.enable {
        enable = true;
        privateRepos = true;
        htpasswd-file = cfg.server.htpasswd-file;
        listenAddress = "127.0.0.1:${toString cfg.server.port}";
      };

      backups = lib.mapAttrs (name: connectionCfg: {
        # TODO: auto mount remote repos - dev shells or something like that
        initialize = true;
        user = "restic";
        package = pkgs.writeShellScriptBin "restic" ''exec /run/wrappers/bin/restic "$@"'';

        repositoryFile = connectionCfg.serverURL;
        passwordFile = connectionCfg.passwordFile;
        environmentFile = connectionCfg.environmentFile;

        paths = data.backupPaths ++ connectionCfg.backupPaths;

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
          "--keep-yearly 1"
        ];

        timerConfig = {
          OnCalendar = "*-*-* 09:00:00";
          Persistent = true;
        };
      }) cfg.backupConnections;
    };

  };
}
