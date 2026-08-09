{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../lib/disko/simple-disk.nix
  ];

  # set to your target disk (run `lsblk` on the target to find it)
  _module.args.disk = "/dev/nvme0n1";

  pillar = {
    users.jwatson.enable = true;
    hardware.thinkpad-T480s.enable = true;
    profiles = {
      desktop.enable = true;
      desktop.desktopEnvironment = "plasma";
    };
    services.ctf.enable = true;
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  system.stateVersion = "26.05";
}
