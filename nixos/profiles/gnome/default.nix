{ config, pkgs, lib, self, ... }:

{
  imports = [
    ./extensions.nix
  ];

  # Remove gnome default apps
  environment.gnome.excludePackages = (with pkgs; [
    # epiphany              # Web browser
    geary                 # Email client
    seahorse              # Password manager
    gnome-calendar
    simple-scan
    gnome-tour
    gnome-connections
    gnome-contacts
    gnome-maps
    gnome-weather
    gnome-clocks
    # keep for now
    # gnome-music           # Music player
  ]);

  # Shell settings
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        lockAll = true; # prevents overriding
        settings = lib.fix (self: with lib.gvariant; {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-enable-primary-paste = false;
            # show-battery-percentage = true;
          };

          # NIGHT SHIFT
          "org/gnome/settings-daemon/plugins/color" = {
            night-light-enabled = true;
            night-light-schedule-automatic = false;
            night-light-schedule-from = 19.0;
            night-light-schedule-to = 10.0;
          };

          # KEYBINDINGS
          "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
              control-center = "<Super>i";
              screensaver = "<Super>l";
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            binding = "<Super>e";
            command = "/usr/bin/env nautilus";
            name = "File Manager";
          };
          
          "org/gnome/desktop/wm/keybindings" = {
            move-to-workspace-left = ["<Control><Alt><Shift>Left" "<Control><Alt><Shift>h" "<Super><Shift>h"];
            move-to-workspace-right = ["<Control><Alt><Shift>Right" "<Control><Alt><Shift>l" "<Super><Shift>l"];
            switch-to-workspace-left = ["<Control><Alt>Left" "<Control><Alt>h"];
            switch-to-workspace-right = ["<Control><Alt>Right" "<Control><Alt>l"];
            switch-to-workspace-1 = [ "<Super>1" ];
            switch-to-workspace-2 = [ "<Super>2" ];
            switch-to-workspace-3 = [ "<Super>3" ];
            switch-to-workspace-4 = [ "<Super>4" ];
            switch-to-workspace-5 = [ "<Super>5" ];
            switch-to-workspace-6 = [ "<Super>6" ];
            switch-to-workspace-7 = [ "<Super>7" ];
            switch-to-workspace-8 = [ "<Super>8" ];
            switch-to-workspace-9 = [ "<Super>9" ];
          };

          "org/gnome/shell/app-switcher".current-workspace-only = true;

          "org/gnome/shell/keybindings" = {
            show-screenshot-ui = [ "<Shift><Super>s" ];
            # switch-to-application-1 = [];
            # switch-to-application-2 = [];
            # switch-to-application-3 = [];
            # switch-to-application-4 = [];
            # switch-to-application-5 = [];
          };
        });
      }
    ];
  };
}
