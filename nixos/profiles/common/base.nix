# Portable baseline config - made for exporting as a module

{ config, lib, pkgs, ... }:

{
  imports = [
    ./fonts.nix
  ];

  custom = {
    services.helix.enable = lib.mkDefault true;
    services.fonts.enable = lib.mkDefault true;
    services.timezone.enable = lib.mkDefault true;
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
    git
    vim
    tmux
    xclip
    fzf
    jq
    btop
    tree
    gh
    radeontop
  ]);

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 14d";
  nix.settings.auto-optimise-store = true;
}
