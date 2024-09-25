{ config, pkgs, inputs, ... }:

{
  imports =
    [
    ];

  
  environment.systemPackages = (with pkgs; [
    # games
    steam
    prismlauncher # minecraft launcher
    jdk17
    jdk8 # Tekkit Classic
  ]);

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
}
