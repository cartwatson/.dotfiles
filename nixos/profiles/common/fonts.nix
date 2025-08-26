{ config, lib, pkgs, ... }:

{
  options.custom.services.fonts = {
    enable = lib.mkEnableOption "Download custom fonts";
    regular-font = lib.mkOption {
      type = lib.types.package;
      default = pkgs.open-sans;
      description = "Default font for gnome";
    };
    monospace-font = lib.mkOption {
      type = lib.types.package;
      default = pkgs.miracode;
      description = "Default monospace font for gnome";
    };
  };

  config = lib.mkIf config.custom.services.fonts.enable {
    # environment.systemPackages = (with pkgs; [
    #   open-sans       # primary font
    #   miracode        # primary monospace
    #   jetbrains-mono  # backup monospace
    # ]);
  };
}
