{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../lib/disko/simple-disk.nix
  ];

  # set to your target disk (run `lsblk` on the target to find it)
  _module.args.disk = "/dev/sda";

  custom = {
    hardware.thinkpad-T480s.enable = true;
    profiles = {
      laptop.enable = true;
      desktop.enable = true;
      desktop.desktopEnvironment = "gnome";
    };
    services = {
      rf.enable = true;
      gaming.enable = true;
      gaming.openttd = true;
      gnome.numWorkspaces = 3;
      gnome.extensions.automoveWindows = [
        "org.gnome.Terminal.desktop:1"
        "firefox.desktop:2"
        "org.gnome.Settings.desktop:3"
      ];
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  system.stateVersion = "26.05";
}
