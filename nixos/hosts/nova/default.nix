{ config, lib, pkgs, pkgs-unstable, settings, nix-minecraft, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  sops.secrets = {
    "api_tokens/github_readonly" = {};
    "api_tokens/cloudflare" = {};
    "glance/location" = {};
  };

  custom = {
    secrets.enable = true;
    services.ssh = {
      enable = true;
      port = 9999;
    };
    services.caddy = {
      enable = true;
      domain = settings.domainName;
    };
    services.ddclient = {
      enable = true;
      cloudfareApiKeyPath = "/run/secrets/api_tokens/cloudflare";
      domainName = settings.domainName;
    };
    services.glance = {
      enable = true;
      proxy = {
        enable = true;
        subdomain = "dashboard";
        internal = false;
        auth = false;
      };
    };
    services.minecraftServer.enable = true;
    services.tailscale = {
      enable = true;
      enableSSH = true;
      proxy = {
        enable = true;
        internal = false;
      };
    };
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
