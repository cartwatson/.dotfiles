{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  sops.secrets = {
    "wireguard/oort/eclipse" = {};
  };

  custom = {
    secrets.enable = true;
    services.timezone.automatic = true;
    services.tailscale.enable = true;
    services.gnome = {
      enable = true;
      numWorkspaces = 3;
      extensions.automoveWindows = [
        "org.gnome.Terminal.desktop:1"
        "firefox.desktop:2"
        "org.gnome.Settings.desktop:3"
      ];
    };
    services.gaming = {
      enable = true;
      openttd = true;
    };
    services.wireguard = {
      enable = true;
      oort =  {
        enable = true;
        privateKeyFile = "/run/secrets/wireguard/oort/eclipse";
      };
    };
  };

  nix.settings.download-buffer-size = 524288000; # 500MB

  environment.systemPackages = (with pkgs; [
    firefox
    kdePackages.kate
  ]);

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
