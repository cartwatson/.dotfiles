{ config, lib, pkgs, pkgs-unstable, nix-minecraft, ... }:

let
  cfg = config.custom.services.minecraftServerBachelor;
  port = 25565;
in
{
  imports = [
    nix-minecraft.nixosModules.minecraft-servers
  ];

  options.custom.services.minecraftServerBachelor = {
    enable = lib.mkEnableOption "Enable Bachelor Minecraft Servers.";
  };

  config = (lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ port ];
      allowedUDPPorts = [ port ]; # Required since you have enable-query = true;
    };

    nixpkgs.overlays = [ nix-minecraft.overlay ];
    services.minecraft-servers = {
      enable = true;
      eula = true;
      servers = {
        bachelor = {
          enable = true;
          package = pkgs.fabricServers.fabric-26_2.override {
            jre_headless = pkgs.openjdk25_headless;
          };

          serverProperties = {
            max-players = 9;
            enable-query = true;
            sync-chunk-writes = false;
            difficulty = "normal";
            gamemode = "survival";
            motd = "By jove, we've hit the mother load";
            server-port = port;
          };

          # RCON_CMDS_STARTUP: gamerule playersSleepingPercentage 1
          symlinks = {
            mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
              # CDN: find link to specific file, and `copy link` from the download button
              # SHA512: `nix-prefetch-url --type sha512 --name <NAME> "<URL>"`
              FerriteCore = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar?mr_download_reason=standalone&mr_game_version=26.1.2&mr_loader=fabric";
                sha512 = "22fbjz59a2qh4bynn6rmplbawi36wgddycwsqvz1x5f11l5355khay5m6kf8xx1bzjcx4vivl1pc00xhcrz9hl95za1jk3q25zaj7yq";
              };
              Fabric-API = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/E1mjhYMF/fabric-api-0.150.0%2B26.1.2.jar?mr_download_reason=standalone&mr_game_version=26.1.2&mr_loader=fabric";
                sha512 = "3f22p9dnm9v2mk4djrlkb7zrjmdh3lkbwvamh73gpvvd51r4ynlsaqyj200yrk4139izyxhyy423kqlqy4clkjnbcnivlhff8xpk313";
              };
              lithium = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/rzrH7czY/lithium-fabric-0.24.4%2Bmc26.1.2.jar?mr_download_reason=standalone&mr_game_version=26.1.2&mr_loader=fabric";
                sha512 = "35bcmy6pyzv9w0zykxxzzfs43p367wqlffaam53ff7ywxqibp5cn6pl4a50gm8gszkdc0h68ry919pg8v77cfralvp6vh4bjrh9chsx";
              };
            });
          };
        };
      };
    };
    # TODO: install mcrcon for RCON commands
  });
}

