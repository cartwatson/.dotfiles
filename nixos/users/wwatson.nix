{ config, lib, pkgs, ... }:

{
  options.pillar.users.wwatson = {
    enable = lib.mkEnableOption "Create user 'wwatson'";
  };

  config = lib.mkIf config.pillar.users.wwatson.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.wwatson = {
      isNormalUser = true;
      initialPassword = "changeme";
      description = "William Watson";
      extraGroups = [
        "wheel"
      ] ++ (lib.optional config.networking.networkmanager.enable "networkmanager");

      packages = with pkgs; lib.lists.optionals config.pillar.profiles.desktop.enable [
        discord
      ];
    };
  };
}

