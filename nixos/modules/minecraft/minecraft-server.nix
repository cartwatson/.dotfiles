{ config, lib, pkgs, pkgs-unstable, nix-minecraft, ... }:

let
  kuiper = import ./kuiper.nix { inherit pkgs; };
  customServers = lib.attrsets.mergeAttrsList [
    kuiper
  ];

  cfg = config.custom.services.minecraftServer;
in
{
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];

  options.custom.services.minecraftServer = {
    enable = lib.mkEnableOption "Enable a Minecraft Server.";
    # TODO: this will break with multiple servers
    port = lib.mkOption {
      type = lib.types.port;
      default = 5003;
      description = "Port for the minecraft server.";
    };
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "playmc";
      description = "The subdomain Caddy should use to reverse proxy.";
    };
  };

  config = (lib.mkIf cfg.enable {
    nixpkgs.overlays = [ nix-minecraft.overlay ];
    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;

      servers = customServers;
    };
  });
}
