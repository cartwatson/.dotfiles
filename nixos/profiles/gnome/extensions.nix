{ config, pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    gnome-tweaks
    gtop # needed for astra-monitor GPU
  ]) ++ (with pkgs.gnomeExtensions; [
    blur-my-shell
    just-perfection
    panel-date-format
    astra-monitor
    auto-move-windows
  ]);

  programs.dconf.profiles.user.databases = [{
    settings = lib.fix (self: with lib.gvariant; {
      "org/gnome/shell" = {
        enabled-extensions = [
          pkgs.gnomeExtensions.blur-my-shell.extensionUuid
          pkgs.gnomeExtensions.just-perfection.extensionUuid
          pkgs.gnomeExtensions.panel-date-format.extensionUuid
          pkgs.gnomeExtensions.astra-monitor.extensionUuid
          pkgs.gnomeExtensions.auto-move-windows.extensionUuid
        ];
      };

      # EXTENSION SPECIFIC SETTINGS
      "org/gnome/shell/extensions/panel-date-format".format = "%Y-%m-%d %H:%M W%V-%u";

      "org/gnome/shell/extensions/auto-move-windows".application-list = [
        "spotify.desktop:1"
        "bitwarden.desktop:2"
        "org.gnome.Terminal.desktop:3"
        "chromium-browser.desktop:4"
        "discord.desktop:5"
        "org.prismlauncher.PrismLauncher.desktop:6"
        "steam.desktop:7"
        "org.gnome.Settings.desktop:9"
      ];

      "org/gnome/shell/extensions/just-perfection" = {
        accessibility-menu = true;
        activities-button = false;
        aggregate-menu = true;
        animation = mkUint32 1;
        app-menu = false;
        app-menu-icon = true;
        app-menu-label = true;
        background-menu = true;
        clock-menu = true;
        clock-menu-position = mkUint32 0;
        clock-menu-position-offset = mkUint32 0;
        controls-manager-spacing-size = mkUint32 0;
        dash = true;
        dash-app-running = true;
        dash-icon-size = mkUint32 0;
        dash-separator = true;
        double-super-to-appgrid = true;
        events-button = true;
        keyboard-layout = true;
        notification-banner-position = mkUint32 1;
        osd = true;
        overlay-key = true;
        panel = true;
        panel-in-overview = true;
        power-icon = true;
        ripple-box = true;
        search = true;
        show-apps-button = true;
        startup-status = mkUint32 1;
        switcher-popup-delay = true;
        theme = false;
        top-panel-position = mkUint32 0;
        weather = true;
        window-demands-attention-focus = false;
        window-picker-icon = true;
        window-preview-caption = true;
        window-preview-close-button = true;
        workspace = true;
        workspace-background-corner-size = mkUint32 0;
        workspace-peek = true;
        workspace-popup = true;
        workspace-switcher-size = mkUint32 0;
        workspace-wrap-around = false;
        workspaces-in-app-grid = true;
        world-clock = true;
      };
    });
  }];
}
