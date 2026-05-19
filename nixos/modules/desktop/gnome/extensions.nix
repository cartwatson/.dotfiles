{ config, pkgs, lib, ... }:

let
  baseCfg = config.custom.services.gnome;
  cfg = baseCfg.extensions;
in
{
  config = lib.mkIf (baseCfg.enable && cfg.enable) {
    # add extensions + manager
    environment.systemPackages = [ pkgs.gnome-tweaks ] ++ cfg.listOfExtensions;

    # TODO: fix this :/
    # clear existing configured settings
    # FUTURE: When other extensions gain configuration then we need to nuke their settings on rebuild as well
    # system.activationScripts.resetDconf = {
    #   text = ''
    #     ${pkgs.dconf}/bin/dconf reset -f /org/gnome/shell/extensions/auto-move-windows;
    #    '';
    # };

    programs.dconf.profiles.user.databases = [{
      settings = with lib.gvariant; {
        # enable all installed extensions
        "org/gnome/shell" = {
          enabled-extensions = map (ext: ext.extensionUuid) cfg.listOfExtensions;
        };

        # extension specific settings
        "org/gnome/shell/extensions/panel-date-format".format = "%Y-%m-%d %H:%M";

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
      };
    }];
  };
}
