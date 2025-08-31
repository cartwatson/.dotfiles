{ config, lib, pkgs, pkgs-unstable, ... }:

let
  steamConfig = {
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

  minecraftConfig = {
    environment.systemPackages = (with pkgs-unstable; [
      # https://wiki.nixos.org/wiki/Prism_Launcher
      (prismlauncher.override {
        # Change Java runtimes available to Prism Launcher
        jdks = [
          jdk17
        ];
      })
    ]);
  };

  sunshineConfig = {
    environment.systemPackages = (with pkgs-unstable; [
      sunshine
    ]);

    services.sunshine = {
      # start service by running `sunshine` in terminal
      enable = false;
      autoStart = false;
      capSysAdmin = true;
      openFirewall = true;
    };

    networking.firewall = {
      enable = true;
      # mystery process on 48010, disabled
      allowedTCPPorts = [ 47984 47989 47990 ];
      allowedUDPPortRanges = [
        { from = 47998; to = 48000; }
        { from = 8000; to = 8010; }
      ];
    };
  };
in
{
  options.custom.services.gaming = {
    enable = lib.mkEnableOption "Enable Gaming.";
    steam = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    minecraft = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    sunshine = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };


  config = lib.mkIf config.custom.services.gaming.enable (
    lib.mkMerge [
      (lib.mkIf config.custom.services.gaming.steam     steamConfig)
      (lib.mkIf config.custom.services.gaming.minecraft minecraftConfig)
      (lib.mkIf config.custom.services.gaming.sunshine  sunshineConfig)
    ]
  );
}
