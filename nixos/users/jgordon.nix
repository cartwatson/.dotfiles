{ config, lib, pkgs, ... }:

{
  options.custom.users.jwatson = {
    enable = lib.mkEnableOption "Create user 'jwatson'";
  };

  config = lib.mkIf config.custom.users.jwatson.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.jwatson = {
      isNormalUser = true;
      initialPassword = "changeme";
      description = "Jessica G. Watson";
      extraGroups = [
        "wheel"
      ] ++ (lib.optional config.networking.networkmanager.enable "networkmanager")
        ++ (lib.optional config.virtualisation.docker.enable "docker");

      packages = [];
    };
  };
}

