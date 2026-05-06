{ settings, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  sops.secrets = {
    "api_tokens/github_readonly" = {};
    "api_tokens/cloudflare" = {};
    "tailscale/auth_key" = {}; # TODO: find this
    "glance/location" = {};
  };

  custom = {
    secrets.enable = true;
    services.timezone.tz = "Etc/Zulu";
    services.tailscale = {
      enable = true;
      authKeyFile = "/run/secrets/tailscale/auth_key";
      ssh.enable = true;
      exit-node.enable = true;
    };
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
      port = 8001;
      proxy = {
        enable = true;
        subdomain = "dashboard";
      };
    };
    services.personal-site = {
      enable = true;
      port = 8002;
    };
    services.minecraftServer.enable = true;
  };

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
  system.stateVersion = "25.05"; # Did you read the comment?
}
