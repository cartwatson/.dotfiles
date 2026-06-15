{ config, lib, pkgs, ... }:

{
  options.custom.users.wwatson = {
    enable = lib.mkEnableOption "Create user 'wwatson'";
  };

  config = lib.mkIf config.custom.users.wwatson.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.wwatson = {
      isNormalUser = true;
      description = "William Watson";
      extraGroups = [
        "wheel"
      ] ++ (lib.optional config.networking.networkmanager.enable "networkmanager");

      packages = with pkgs; lib.lists.optionals config.custom.profiles.desktop.enable [
        discord
      ];
    };
  };
}

