{ config, lib, pkgs, ... }:

{
  options.custom.services.fonts = {
    enable = lib.mkEnableOption "Download custom fonts";
  };

  config = lib.mkIf config.custom.services.fonts.enable {
    environment.systemPackages = (with pkgs; [
      open-sans       # primary font
      miracode        # primary monospace
      jetbrains-mono  # backup monospace
    ]);
  };
}
