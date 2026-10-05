{ config, lib, pkgs, pkgs-unstable, nix-minecraft, ... }:

let
  baseCfg = config.pillar.services;
  cfg = baseCfg.minecraftServer;

  customServers = lib.attrsets.mergeAttrsList [
    (import ./kuiper.nix { inherit pkgs; })
  ];
in
{
  imports = [
    nix-minecraft.nixosModules.minecraft-servers
  ];

  options.pillar.services.minecraftServer = {
    enable = lib.mkEnableOption "Enable Minecraft Servers.";
  };

  config = (lib.mkIf cfg.enable {
    nixpkgs.overlays = [ nix-minecraft.overlay ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      # NOTE: manually create SRV records for each server
      openFirewall = true;

      servers = customServers;

      # NOTE: comment this to force all output to tmux instead of journal
      # NOTE: no clue why you would want to do that honestly
      # REF: https://github.com/Infinidoge/nix-minecraft/issues/119
      managementSystem.systemd-socket.enable = true;
    };
  });
}
