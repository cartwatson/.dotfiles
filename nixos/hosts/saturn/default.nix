{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  pillar.profiles.desktop = {
    enable = true;
    desktopEnvironment = "gnome";
  };

  pillar = {
    secrets = {
      enable = true;
      keyFile = "/var/lib/custom-sops/keys.txt";
    };
    services.tailscale = {
      authKeyFile = "/run/secrets/tailscale/auth_key";
      ssh.enable = true;
    };
    users.wwatson.enable = true;
    services.fonts.enable = lib.mkForce false;
    services.timezone.tz = "America/Denver";
    services.gnome = {
      enable = true;
      numWorkspaces = 1;
      allowOverride = true;
      terminal.customize = false;
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

  system.stateVersion = "25.11"; # Only change if device is reimaged
}
