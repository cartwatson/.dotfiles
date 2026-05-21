{ config, lib, pkgs, ... }:

{
  options.custom.users.jgordon = {
    enable = lib.mkEnableOption "Create user 'jgordon'";
  };

  config = lib.mkIf config.custom.users.jgordon.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.jgordon = {
      isNormalUser = true;
      description = "Jess Gordon";
      extraGroups = [
        "wheel"
      ] ++ (lib.optional config.networking.networkmanager.enable "networkmanager")
        ++ (lib.optional config.virtualisation.docker.enable "docker");

      packages = [];
    };
  };
}

