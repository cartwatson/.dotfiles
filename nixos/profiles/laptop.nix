{ config, lib, pkgs, ... }:

let
  cfg = config.custom.profiles.laptop;
in
{
  options.custom.profiles.laptop = {
    enable = lib.mkEnableOption "Enable default laptop config.";
  };

  config = lib.mkIf (cfg.enable && config.custom.profiles.desktop.desktopEnvironment == "gnome") {
    custom.services.gnome.numWorkspaces = 3;
    custom.services.gnome.extensions.automoveWindows = [
      "org.gnome.Terminal.desktop:1"
      "firefox.desktop:2"
      "chromium-browser.desktop:2"
      "org.gnome.Settings.desktop:3"
    ];
  };
}
