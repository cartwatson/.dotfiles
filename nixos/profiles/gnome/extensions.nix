{ config, pkgs, lib, self, ... }:

{
  environment.systemPackages = (with pkgs; [
    gnome-tweaks
  ]) ++ (with pkgs.gnomeExtensions; [
    blur-my-shell
    just-perfection
    panel-date-format
  ]);

  programs.dconf.profiles.user.databases = [{
    settings = lib.fix (self: with lib.gvariant; {
      "org/gnome/shell" = {
        enabled-extensions =
          builtins.map
            (lib.getAttr "extensionUuid")
            (lib.filter (lib.hasAttr "extensionUuid") config.environment.systemPackages);
      }

      # EXTENSION SPECIFIC SETTINGS
      "org/gnome/shell/extensions/panel-date-format".format = "%Y-%m-%d %H:%M";

      "org/gnome/shell/extensions/just-perfection" = {
        accessibility-menu=true;
        activities-button=false;
        aggregate-menu=true;
        # animation=1;
        app-menu=false;
        app-menu-icon=true;
        app-menu-label=true;
        background-menu=true;
        clock-menu=true;
        # clock-menu-position=0;
        # clock-menu-position-offset=0;
        # controls-manager-spacing-size=0;
        dash=true;
        dash-app-running=true;
        # dash-icon-size=0;
        dash-separator=true;
        double-super-to-appgrid=true;
        events-button=true;
        keyboard-layout=true;
        # notification-banner-position=1;
        osd=true;
        overlay-key=true;
        panel=true;
        panel-in-overview=true;
        power-icon=true;
        ripple-box=true;
        search=true;
        show-apps-button=true;
        # startup-status=1;
        switcher-popup-delay=true;
        theme=false;
        # top-panel-position=0;
        weather=true;
        window-demands-attention-focus=false;
        window-picker-icon=true;
        window-preview-caption=true;
        window-preview-close-button=true;
        workspace=true;
        # workspace-background-corner-size=0;
        workspace-peek=true;
        workspace-popup=true;
        # workspace-switcher-size=0;
        workspace-wrap-around=false;
        workspaces-in-app-grid=true;
        world-clock=true;
      };
    });
  }];
}
