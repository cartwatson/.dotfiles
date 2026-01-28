# IMPORTANT: Included pkgs & settings for **ALL** configurations

{ config, lib, pkgs, ... }:

{
  imports = [
    ./fonts.nix
    ./timezone.nix # always enabled
    ./gui.nix
  ];

  custom = {
    services.helix.enable = lib.mkDefault true;
    services.fonts.enable = lib.mkDefault true;

    users.cwatson.enable = lib.mkDefault true;
    users.wwatson.enable = lib.mkDefault false;
    users.jgordon.enable = lib.mkDefault false;
  };

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
    # tools
    git
    vim
    tmux
    xclip # needed for tmux->system_clipboard functionality

    # utilities
    jq
    btop
    tree
  ]);

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # garbage collect everything older two weeks
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 14d";
  nix.settings.auto-optimise-store = true;
}
