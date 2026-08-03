{ config, lib, ... }:

let
  cfg = config.custom.services.timezone;
in
{
  options.custom.services.timezone = {
    enable = lib.mkEnableOption "Enable custom timezone service";
    tz = lib.mkOption {
      type = lib.types.str;
      default = "America/Los_Angeles";
      description = "String form of local timezone (https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)";
    };
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = lib.mkDefault cfg.tz;
  };
}
