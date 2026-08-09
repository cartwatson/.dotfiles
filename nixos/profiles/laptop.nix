{ config, lib, pkgs, ... }:

let
  cfg = config.pillar.profiles.laptop;
in
{
  options.pillar.profiles.laptop = {
    enable = lib.mkEnableOption "Enable default laptop config.";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && config.pillar.profiles.desktop.desktopEnvironment == "gnome") {
      pillar.services.gnome.numWorkspaces = 3;
      pillar.services.gnome.extensions.automoveWindows = [
        "org.gnome.Terminal.desktop:1"
        "firefox.desktop:2"
        "chromium-browser.desktop:2"
        "org.gnome.Settings.desktop:3"
      ];
    })
    (lib.mkIf (cfg.enable) {
      environment.systemPackages = (with pkgs; [
        # TODO: something here later I guess, good infra to have
      ]);
    })
  ];
}
