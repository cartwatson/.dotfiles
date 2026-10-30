{ config, pkgs, lib, ... }:

let
  cfg = config.pillar.services.icecast;
  data = config.pillar.data;
in
{
  options.pillar.services.icecast = {
    enable = lib.mkEnableOption "icecast.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for icecast.";
    };
    proxy = {
      enable = lib.mkEnableOption "Enable proxy";
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "icecast";
        description = "The subdomain the proxy should use to reverse proxy.";
      };
      auth = lib.mkEnableOption "Should the proxy require auth to access this service.";
    };
   };

  config = lib.mkIf cfg.enable {
    assertions = [
    ];

    services.icecast = {
      enable = true;
      listen.address = "127.0.0.1"; # NOTE: assumes proxying is on
      listen.port = cfg.port;
      extraConfig = ''
      <mount type="default">
        <public>0</public>
        <intro>/stream.m3u</intro>
      </mount>
      '';
    };
  };
}
