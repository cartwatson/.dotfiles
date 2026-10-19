{ config, lib, nix-minecraft, ... }:

let
  baseCfg = config.pillar.services;
  cfg = baseCfg.minecraftServer;
in
{
  imports = [
    nix-minecraft.nixosModules.minecraft-servers
  ];

  options.pillar.services.minecraftServer = {
    enable = lib.mkEnableOption "Enable Minecraft Servers.";
    servers = lib.mkOption {
      default = {};
      description = "Minecraft servers to run.";
      type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
        options = {
          port = lib.mkOption { type = lib.types.port; };
          pkg = lib.mkOption { type = lib.types.package; };
          maxPlayers = lib.mkOption { type = lib.types.int; default = 10; };
          worldType = lib.mkOption { type = lib.types.enum [ "peaceful" "easy" "normal" "hard" "creative" ]; default = "normal"; };
          motd = lib.mkOption { type = lib.types.str; };
          whitelist = lib.mkOption {
            type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
            default = null;
          };
          mods = lib.mkOption { type = lib.types.nullOr lib.types.package; default = null; };
        };
      }));
    };
  };

  config = (lib.mkIf cfg.enable {
    nixpkgs.overlays = [ nix-minecraft.overlay ];

    # add **all** world data to backups
    pillar.data.backupPaths = lib.mapAttrsToList (name: _:
     "/srv/minecraft/${name}"
    ) cfg.servers;

    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;

      # NOTE: manually create SRV records for each server
      servers = lib.mapAttrs (name: serverCfg: {
        enable = true;
        package = serverCfg.pkg;
        whitelist = serverCfg.whitelist;
        symlinks.mods = serverCfg.mods;
        # RCON_CMDS_STARTUP: gamerule playersSleepingPercentage 1

        # 2GB minimum
        # 500MB/player + 2GB minimum
        jvmOpts = "-Xms2G -Xmx${toString (serverCfg.maxPlayers * 500 + 2048)}m";

        serverProperties = {
          server-port = serverCfg.port;
          max-players = serverCfg.maxPlayers;
          white-list = serverCfg.whitelist != null;
          enable-query = true;
          sync-chunk-writes = false;
          difficulty = if serverCfg.worldType == "creative" then "medium" else serverCfg.worldType;
          gamemode = if serverCfg.worldType != "creative" then "survival" else serverCfg.worldType;
          motd = serverCfg.motd;
        };
      }) cfg.servers;

      # NOTE: comment this to force all output to tmux instead of journal
      # NOTE: no clue why you would want to do that honestly
      # REF: https://github.com/Infinidoge/nix-minecraft/issues/119
      managementSystem.systemd-socket.enable = true;
    };
  });
}
