# IMPORTANT: Included pkgs & settings for **ALL** configurations

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/helix.nix
  ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = (with pkgs; [
    git
    vim
    tmux
    xclip # needed for tmux->system_clipboard functionality
    htop
    fastfetch # new neofetch
    caligula # ISO Burner - [git](https://github.com/ifd3f/caligula/tree/main)
  ]);

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cwatson = {
      isNormalUser = true;
      description = "Carter Watson";
      extraGroups = [ "networkmanager" "wheel" ];
      uid = 1000;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # auto updating can be done with these commands
  # https://nixos.org/manual/nixos/stable/index.html#sec-upgrading-automatic
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # garbage collect everything older two weeks
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 14d";
  nix.settings.auto-optimise-store = true;
}
