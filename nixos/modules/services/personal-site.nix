{ config, lib, pkgs, ... }:

let
  cfg = config.custom.services.personal-site;
  repo-url = "https://github.com/cartwatson/cartwatson.github.io";
  stateDir = "personal-site";
  dir = "/var/lib/${stateDir}";
in
{
  options.custom.services.personal-site = {
    enable = lib.mkEnableOption "Enable hosting personal site";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to host personal-site on";
    };
  };

  config = lib.mkIf cfg.enable {
    # Custom user+group for ownership of files
    users.users.personal-site-user = {
      isSystemUser = true;
      group = "personal-site";
      description = "User to own ${dir}";
    };
    users.groups.personal-site = {};

    # systemd service that hosts site
    systemd.services.personal-site = {
      description = "Host personal site";
      wantedBy = [ "multi-user.target" ]; # Starts at boot
      after = [ "network.target" "update-personal-site.service" ]; # Ensures network and updater are up first

      serviceConfig = {
        Type = "simple";
        User = "personal-site-user";
        StateDirectory = stateDir;
        Restart = "on-failure";

        ExecStart = "${lib.getExe pkgs.httplz} --port ${toString cfg.port} ${dir}/out/";
      };
    };

    # oneshot service controlled by timer to update site
    systemd.services.update-personal-site = {
      description = "Update personal site content";
      after = [ "network.target" ]; # Ensures network is up first
      path = [
        pkgs.git
        pkgs.coreutils
        pkgs.nix
      ];

      serviceConfig = {
        Type = "oneshot";
        User = "personal-site-user";
        StateDirectory = stateDir;

        ExecStart = [
          "rm -rf ${dir}"
          "git clone ${repo-url} --depth 1 ${dir}"
          "nix run github:cartwatson/calcite ${dir}"
        ];
      };
    };

    # timer to update daily
    systemd.timers.update-personal-site = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "0";
        OnCalendar = "daily";
        Persistent = true;  # Run missed executions after downtime
      };
    };
  };
}


