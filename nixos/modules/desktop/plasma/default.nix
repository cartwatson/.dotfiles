{ config, lib, pkgs, ... }:

let
  cfg = config.pillar.services.plasma;
in
{
  options.pillar.services.plasma = {
    enable = lib.mkEnableOption "Setup Plasma";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    services.desktopManager.plasma6.enable = true;

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
    ];
  };
}
