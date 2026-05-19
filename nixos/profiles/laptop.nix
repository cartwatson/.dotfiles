{ config, lib, pkgs, ... }:

let
  cfg = config.custom.profiles.laptop;
in
{
  options.custom.profiles.laptop = {
    enable = lib.mkEnableOption "Enable default laptop config.";
  };

  config = lib.mkIf cfg.enable {
    custom.services.timezone.automatic = true;
  };
}
