{ config, lib, pkgs, pkgs-unstable, ... }:

let
  cfg = config.custom.services.gaming;
in
{
  options.custom.services.gaming = {
    steam = lib.mkEnableOption "Install Steam";
  };

  config = lib.mkIf (cfg.enable && cfg.steam) {
    environment.systemPackages = (with pkgs-unstable; [
      steam
      protontricks
    ]);

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers

      protontricks.enable = true;
    };
  };
}

