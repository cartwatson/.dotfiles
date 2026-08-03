# Baseline config

{ config, lib, pkgs, ... }:

{
  imports = [
    ./fonts.nix
  ];

  custom = {
    users.cwatson.enable = lib.mkDefault true;
    users.wwatson.enable = lib.mkDefault false;
    users.jwatson.enable = lib.mkDefault false;

    services.tmux.enable = lib.mkDefault true;
    services.helix.enable = lib.mkDefault true;
    services.fonts.enable = lib.mkDefault true;
    services.timezone.enable = true;
  };

  # TODO: test this out in the future, could be useful for live-iso ssh access/discovery
  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   publish.enable = true;
  #   publish.addresses = true;
  # };

  # Enable firmware updates
  hardware.enableRedistributableFirmware = true;

  # Enable networking
  networking.networkmanager.enable = lib.mkDefault true;

  # Select internationalisation properties.
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = lib.mkDefault "en_US.UTF-8";
    LC_IDENTIFICATION = lib.mkDefault "en_US.UTF-8";
    LC_MEASUREMENT    = lib.mkDefault "en_US.UTF-8";
    LC_MONETARY       = lib.mkDefault "en_US.UTF-8";
    LC_NAME           = lib.mkDefault "en_US.UTF-8";
    LC_NUMERIC        = lib.mkDefault "en_US.UTF-8";
    LC_PAPER          = lib.mkDefault "en_US.UTF-8";
    LC_TELEPHONE      = lib.mkDefault "en_US.UTF-8";
    LC_TIME           = lib.mkDefault "en_US.UTF-8";
  };

  environment.systemPackages = (with pkgs; [
    git
    vim
    fzf       # needed for bashrc
    jq        # nice to have
    tree      # nice to have
    btop      # system monitor
    radeontop # needed for btop
  ]);

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 30d";
  nix.settings.auto-optimise-store = true;
}
