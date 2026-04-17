{ config, lib, pkgs, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.openttd.server;
  mainDir = "/var/lib/openttd";
  configDir = "${mainDir}/.openttd";
  configFile = pkgs.writeText "openttd.cfg" ''
    [network]
    server_name = ${cfg.serverName}
    server_password = ${cfg.serverPassword}
    server_advertise = ${lib.boolToString cfg.advertise}
    pause_on_join = true
    min_active_clients = 1
    reload_cfg = true

    [ai]
    ai_in_multiplayer = false

    [gui]
    autosave = 2
    max_num_autosaves = 16
  '';
in
{
  options.custom.services.openttd.server = {
    enable = lib.mkEnableOption "Create an OpenTTD Server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3979;
      description = "Port for the OpenTTD server.";
    };
    serverName = lib.mkOption {
      type = lib.types.str;
      default = "NixOS OpenTTD Server";
      description = "Name shown in the server browser.";
    };
    serverPassword = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Password to join the server. Empty for no password.";
    };
    advertise = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to advertise the server publicly.";
    };
    savegame = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a save game to load. Starts a new game if null.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.openttd = {
      isSystemUser = true;
      group = "openttd";
      home = mainDir;
      createHome = true;
      description = "OpenTTD server user";
    };

    users.groups.openttd = { };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    systemd.services.openttd-server = {
      description = "OpenTTD Dedicated Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "openttd";
        Group = "openttd";
        WorkingDirectory = mainDir;
        # copy config file var to disk but only if it doesn't exist already
        # NOTE: If you change serverName, serverPassword, advertise, or saveGame
        #       you will need to delete or manually update the cfg file
        ExecStartPre = "${pkgs.bash}/bin/bash -c 'test -f ${configDir}/openttd.cfg || ${pkgs.coreutils}/bin/install -Dm644 ${configFile} ${configDir}/openttd.cfg'";
        # 0.0.0.0 will accept traffic from everywhere
        ExecStart = "${lib.getExe pkgs.openttd} -D 0.0.0.0:${toString cfg.port}${lib.optionalString (cfg.savegame != null) " -g ${cfg.savegame}"}";
        Restart = "on-failure";
      };
    };
  };
}
