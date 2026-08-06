{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../lib/disko/simple-disk.nix
  ];

  # set to your target disk (run `lsblk` on the target to find it)
  _module.args.disk = "/dev/sda";

  pillar = {
    hardware.thinkpad-T480s.enable = true;
    profiles = {
      laptop.enable = true;
      desktop.enable = true;
    };
    services = {
      rf.enable = true;
      ctf.enable = true;
      gaming.enable = true;
      gaming.openttd = true;
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  system.stateVersion = "26.05";
}
