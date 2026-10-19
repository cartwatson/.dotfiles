{ config, pkgs, lib, ... }:

let
  baseCfg = config.pillar.services;
  cfg = baseCfg.restic;
  data = config.pillar.data;
in
{
  options.pillar.services.restic = {
    enable = lib.mkEnableOption "Enable Restic.";
    server = {
      enable = lib.mkEnableOption "Enable Restic's server on this device.";
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
        enable = lib.mkEnableOption "Enable proxy";
        subdomain = lib.mkOption {
          type = lib.types.str;
          default = "grafana";
          description = "The subdomain the proxy should use to reverse proxy.";
        };
        auth = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Should the proxy require auth to access this service.";
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
        assertion = cfg.proxy.enable -> cfg.server.enable;
        message = "pillar.services.restic.proxy: Server must be enabled for proxy to work.";
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
      permissions = "500"; # or u=rx,g=,o=
      capabilities = "cap_dac_read_search+ep";
    };

    pillar.data.forwardedServices = lib.mkIf cfg.server.enable [ cfg.server ];
    services.restic = {
      server = lib.mkIf cfg.server.enable {
        enable = true;
        htpasswd-file = cfg.server.htpasswd-file;
        listenAddress = "127.0.0.1:${cfg.server.port}";
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
