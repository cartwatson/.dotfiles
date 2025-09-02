{ config, lib, pkgs, pkgs-unstable, ... }:

{
  options.custom.services.glance = {
    enable = lib.mkEnableOption "Enable Glance.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8001;
      description = "Port for the glance server.";
    };
  };

  config = lib.mkIf config.custom.services.glance.enable {
    services.glance = {
      enable = true;
      openFirewall = true; # DEBUG: remove after caddy
      settings = {
        server.port = config.custom.services.glance.port;
        # pages = {};
      };
    };
  };
}
