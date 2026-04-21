{ config, pkgs, lib, ... }:

let
  cfg = config.custom.services.gnome.extensions;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.gnome-tweaks ] ++ cfg.listOfExtensions;

    programs.dconf.profiles.user.databases = [{
      settings = lib.fix (_self: with lib.gvariant; {
        "org/gnome/shell" = {
          enabled-extensions = map (ext: ext.extensionUuid) cfg.listOfExtensions;
        };

        # EXTENSION SPECIFIC SETTINGS
        "org/gnome/shell/extensions/panel-date-format".format = "%Y-%m-%d %H:%M";

        # NOTE: if any other extensions end up configurable then we need to nuke
        # their settings on rebuild as well
        system.activationScripts.resetDconf = {
          text = "${pkgs.dconf}/bin/dconf reset -f /org/gnome/shell/extensions/auto-move-windows";
        };
        "org/gnome/shell/extensions/auto-move-windows".application-list = cfg.automoveWindows;

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
  };
}
