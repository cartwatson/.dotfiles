{ config, lib, pkgs, pkgs-unstable, nix-minecraft, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.minecraftServer;

  customServers = lib.attrsets.mergeAttrsList [
    (import ./kuiper.nix { inherit pkgs; })
  ];
in
{
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];

  options.custom.services.minecraftServer = {
    enable = lib.mkEnableOption "Enable Minecraft Servers.";
  };

  config = (lib.mkIf cfg.enable {
    nixpkgs.overlays = [ nix-minecraft.overlay ];

    # TODO: install mcrcon for RCON commands

    services.minecraft-servers = {
      enable = true;
      eula = true;
      # NOTE: manually create SRV records for each server
      openFirewall = true;

      servers = customServers;
    };
  });
}
