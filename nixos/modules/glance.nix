{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
  ];

  options.custom.services.glance = {
    enable = lib.mkEnableOption "Enable Glance.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8001;
      description = "Port for the SSH server and related services/protections.";
    };
  };

  config = lib.mkIf config.custom.services.glance.enable {
    services.glance = {
      enable = true;
      openFirewall = true; # DEBUG
      settings = {
        server.port = config.custom.services.glance.port;
        server.host = "0.0.0.0";
    #     pages = {};
      };
    };
  };
}
