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
            type = lib.types.path;
            description = "Path to secret containing serverURL";
          };
          passwordFile = lib.mkOption {
            type = lib.types.path;
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

        paths = data.backupPaths ++ connectionCfg.backupPaths;

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 75"
        ];

        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };

        # Encryption key for repository
        passwordFile = connectionCfg.passwordFile;
        repositoryFile = connectionCfg.serverURL;
      }) cfg.backupConnections;
    };

  };
}
