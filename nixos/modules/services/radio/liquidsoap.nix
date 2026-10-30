# NOTE: only supports liq files
{ config, pkgs, lib, ... }:

let
  cfg = config.pillar.services.liquidsoap;
  data = config.pillar.data;

  liqFiles = lib.filter.attrs (_: v: v.liqFile != null) cfg.streams;
in
{
  options.pillar.services.liquidsoap = {
    enable = lib.mkEnableOption "liquidsoap.";
    streams = lib.mkOption {
      default = {};
      description = "Liquidsoap streams.";
      type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
        options = {
          liqFile = lib.mkOption { type = lib.types.nullOr lib.types.path; };
          # mountpoint = lib.mkOption { type = lib.types.nullOr lib.types.path; }; # TODO: add support before commiting probably
        };
      }));
    };
   };

  config = lib.mkIf cfg.enable {
    assertions = [
    ];

    systemd.tmpfiles.rules = lib.mapAttrsToList (name: streamCfg:
    #  L+ /symlink/to/[re]create      - - - - symlink/target/path
      "L+ /etc/liquidsoap/${name}.liq - - - - ${streamCfg.liqFile}"
    ) liqFiles;

    liquidsoap.streams = lib.mapAttrs (name: streamCfg: {
      "${name}" = streamCfg.liqFile;
    }) liqFiles;
    # liquidsoap.streams = {
    #   jungle = ''
    #     output.icecast(
    #       %vorbis,
    #       host="localhost",
    #       port=8000,
    #       password="hackme",
    #       mount="jungle.ogg",
    #       playlist("~/radio/music.m3u")
    #     )
    #   '';
    # };
  };
}
