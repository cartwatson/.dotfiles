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
    };
    backupConnections = lib.mkOption {
      default = { };
      description = "Servers to connect to for backups";
      type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
        options = {
          serverURL = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to secret containing serverURL";
          };
          passwordFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
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
    # TODO: rename all assertions so I know where they're from
    assertions = lib.mapAttrsToList (name: c: {
      assertion = c.environmentFile == null -> (c.passwordFile != null && c.serverURL != null);
      message = "pillar.services.restic.backupConnections.${name}: `environmentFile` or (`passwordFile` + `serverURL`) must be non-null.";
    }) cfg.backupConnections
    ++ [
      {
        assertion = cfg.server.enable -> cfg.server.htpasswd-file != null;
        message = "pillar.services.restic.server: htpasswd-file is required (rest-server won't start without auth configured).";
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

    services.restic = {
      server = lib.mkIf cfg.server.enable {
        enable = true;
        htpasswd-file = cfg.server.htpasswd-file;
      };

      backups = lib.mapAttrs (name: connectionCfg: {
        initialize = true;
        user = "restic";
        package = pkgs.writeShellScriptBin "restic" ''exec /run/wrappers/bin/restic "$@"'';

        # no problems setting these null, assertion will catch bad setups
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
