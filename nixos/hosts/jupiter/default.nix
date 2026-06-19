{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  custom.profiles.desktop = {
    enable = true;
    desktopEnvironment = "gnome";
  };

  custom = {
    secrets.enable = true;
    services.gnome = {
      numWorkspaces = 7;
      extensions.automoveWindows = [
        "spotify.desktop:1"
        "bitwarden.desktop:2"
        "org.gnome.Terminal.desktop:3"
        "chromium-browser.desktop:4"
        "org.prismlauncher.PrismLauncher.desktop:5"
        "steam.desktop:5"
        "discord.desktop:6"
        "element-desktop.desktop:6"
        "org.gnome.Settings.desktop:7"
      ];
    };
    services.gaming = {
      enable = true;
      steam = true;
      minecraft = true;
      openttd = true;
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics.enable = true;

  system.stateVersion = "24.05"; # Only change if machine is reimaged
}
