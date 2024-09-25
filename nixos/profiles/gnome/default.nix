{ config, pkgs, lib, self, ... }:

{
  imports = [
    # ./debloat.nix
    # ./extensions.nix
  ];


  environment.systemPackages = (with pkgs; [
    # desktop/ricing
    gnome-tweaks
  ]) ++ (with pkgs.gnomeExtensions; [
    blur-my-shell
    gtile
  ]);


  # Disable gnome default apps
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
    # keep for now
    # gnome-music           # Music player
  ]);

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        lockAll = true; # prevents overriding
        settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-enable-primary-paste = false;
            # show-battery-percentage = true;
          };
        };
      }
    ];
  };

  # sessionVariables.GTK_THEME = "adw-gtk3-dark";

  # "org/gnome/desktop/interface" = {
  #   color-scheme = "prefer-dark";
  # };

  # "org/gnome/desktop/wm/keybindings" = {

  # }

  # "org/gnome/shell/keybindings" = {
  #   # Following binds need to be disabled, as their defaults are used for
  #   # the binds above, and will run into conflicts.
  #   switch-to-application-1 = lib.gvariant.mkEmptyArray lib.type.string;
  #   switch-to-application-2 = lib.gvariant.mkEmptyArray lib.type.string;
  #   switch-to-application-3 = lib.gvariant.mkEmptyArray lib.type.string;
  #   switch-to-application-4 = lib.gvariant.mkEmptyArray lib.type.string;
  # };
}
