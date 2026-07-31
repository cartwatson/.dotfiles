{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../lib/disko/simple-disk.nix
  ];

  # set to your target disk (run `lsblk` on the target to find it)
  _module.args.disk = "/dev/sda";

  custom.profiles.desktop = {
    enable = true;
    desktopEnvironment = "gnome";
  };

  # custom.profiles.laptop.enable = true;
  # custom.secrets.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  # boot.initrd.kernelModules = [ "amdgpu" ];
  # hardware.graphics.enable = true;

  # TODO: on install verify this is the correct version, then delete this comment
  system.stateVersion = "26.05"; }
