{ config, lib, pkgs, pkgs-bleedingedge, ... }:

let
  cfg = config.custom.services.plasma;
in
{
  options.custom.services.plasma = {
    enable = lib.mkEnableOption "Setup Plasma";
  };

  imports = [
    ../common/gui.nix
  ];

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
      services.desktopManager.plasma6.enable = true;

      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        konsole
        elisa
      ];
    })
  ];
}
