{ config, pkgs, lib, ... }:

let
  cfg = config.pillar.services.radio;
  data = config.pillar.data;
in
{
  options.pillar.services.radio = {
    enable = lib.mkEnableOption "radio.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for radio.";
    };
    proxy = {
      enable = lib.mkEnableOption "Enable proxy";
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "radio";
        description = "The subdomain the proxy should use to reverse proxy.";
      };
      auth = lib.mkEnableOption "Should the proxy require auth to access this service.";
    };
   };

  config = lib.mkIf cfg.enable {
    assertions = [
    ];

    pillar.services = {
      icecast = {

      };
      liquidsoap = {
        streams.liqFile = pkgs.writeTextFile {
          name = "jungle";
          text = ''
          output.icecast(
            %vorbis,
            host="localhost",
            port=${cfg.port},
            mount="jungle.ogg",
            playlist("/etc/radio/music.m3u")
          )
          '';
        };
      };
    };
  };
}
