{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../lib/disko/simple-disk.nix
  ];

  # set to your target disk (run `lsblk` on the target to find it)
  _module.args.disk = "/dev/sda";

  custom.profiles.laptop.enable = true;
  custom.profiles.desktop = {
    enable = true;
    desktopEnvironment = "gnome";
  };

  custom.services = {
    ctf.enable = true;
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  system.stateVersion = "26.05";
}
