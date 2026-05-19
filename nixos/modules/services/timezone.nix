{ config, lib, ... }:

let
  cfg = config.custom.services.timezone;
in
{
  options.custom.services.timezone = {
    enable = lib.mkEnableOption "Enable custom timezone service";
    automatic = lib.mkEnableOption "Automatically search for timezone";
    tz = lib.mkOption {
      type = lib.types.str;
      default = "America/Los_Angeles";
      description = "String form of local timezone (https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
      # set timezone with low priority
      time.timeZone = lib.mkDefault cfg.tz;
    })

    (lib.mkIf cfg.automatic {
      # enable auto overriding of timezone if enabled
      services.automatic-timezoned.enable = true;
    })
  ]);
}
