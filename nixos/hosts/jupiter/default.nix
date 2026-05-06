{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    secrets.enable = true;
    services.tailscale.enable = true;
    services.gnome = {
      enable = true;
      numWorkspaces = 9;
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
      sunshine = true;
      openttd = true;
    };
  };

  environment.systemPackages = (with pkgs; [
  ]);

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
