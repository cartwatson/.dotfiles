{ config, lib, pkgs, pkgs-bleedingedge, ... }:

let
  cfg = config.custom.services.gnome;
in
{
  options.custom.services.gnome = {
    enable = lib.mkEnableOption "Setup Gnome";
    num-workspaces = lib.mkOption {
      type = lib.types.int;
      default = 7;
      description = "Number of Gnome workspaces";
    };
  };

  imports = [
    ./terminal.nix
    ./extensions.nix

    ../common/gui.nix
  ];

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # Enable the GNOME Desktop Environment.
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;

      # Enable the X11 windowing system.
      services.xserver.enable = true;

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Remove gnome default apps
      services.xserver.excludePackages = [ pkgs.xterm ];

      environment.gnome.excludePackages = (with pkgs; [
        epiphany              # Web browser
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
        gnome-console
        # keep for now
        # gnome-music           # Music player
      ]);

      # Shell settings
      # USE `dconf dump / > dconf-backup.txt`
      # ^ Source [askUbuntu](https://askubuntu.com/questions/522833/how-to-dump-all-dconf-gsettings-so-that-i-can-compare-them-between-two-different)
      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            lockAll = true; # prevents overriding
            settings = lib.fix (_self: with lib.gvariant; {
              # BASIC GNOME SETTINGS
              "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
                gtk-theme = "Yaru-blue-dark";
                gtk-enable-primary-paste = false;
                show-battery-percentage = false;
                enable-hot-corners = false;
                font-name = "Open Sans 11";
                document-font-name = "Open Sans 11";
                monospace-font-name = "Miracode 12";
                # TODO:
                # create a setting to determine what font to use
                # monospace-font-name = "JetBrains Mono Medium 12";
              };

              "org/gnome/desktop/notifications" = {
                show-in-lock-screen = false;
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
                  control-center = ["<Super>i"];
                  screensaver = ["<Super>l"];
              };

              "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
                binding = ["<Super>e"];
                command = "nautilus";
                name = "File Manager";
              };

              "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
                binding=["<Shift><Super>s"];
                command="flameshot gui";
                name="Screenshot Flameshot";
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

              "org/gnome/desktop/wm/preferences" = {
                focus-mode="sloppy";
                num-workspaces=lib.gvariant.mkInt32 cfg.num-workspaces;
              };

              "org/gnome/shell/app-switcher".current-workspace-only = true;

              "org/gnome/shell/keybindings" = {
                switch-to-application-1 = mkEmptyArray type.string;
                switch-to-application-2 = mkEmptyArray type.string;
                switch-to-application-3 = mkEmptyArray type.string;
                switch-to-application-4 = mkEmptyArray type.string;
                switch-to-application-5 = mkEmptyArray type.string;
                switch-to-application-6 = mkEmptyArray type.string;
                switch-to-application-7 = mkEmptyArray type.string;
                switch-to-application-8 = mkEmptyArray type.string;
                switch-to-application-9 = mkEmptyArray type.string;
              };
            });
          }
        ];
      };
    })
  ];
}
