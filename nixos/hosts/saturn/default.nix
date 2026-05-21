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
    services.tailscale = {
      authKeyFile = "/run/secrets/tailscale/auth_key";
      ssh.enable = true;
    };
    users.wwatson.enable = true;
    services.timezone.tz = "America/Denver";
    services.fonts.enable = false;
    services.gnome = {
      enable = true;
      numWorkspaces = 1;
      allowOverride = true;
      terminal.enable = false;
      extensions.listOfExtensions = (with pkgs.gnomeExtensions; [
        just-perfection
        user-themes
      ]) ++ [
        pkgs.gnome49Extensions."dash-to-dock@micxgx.gmail.com"
      ];
    };
    services.gaming = {
      enable = true;
      steam = true;
      minecraft = true;
      openttd = true;
    };
  };

  environment.systemPackages = (with pkgs; [
    firefox

    # GAME DEV
    godot
    godot-export-templates-bin
  ]);

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
