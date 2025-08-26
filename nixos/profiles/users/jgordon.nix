{ config, lib, pkgs, pkgs-unstable, ... }:

{
  options.custom.users.jgordon = {
    enable = lib.mkEnableOption "Create user 'jgordon'";
  };

  config = lib.mkIf config.users.jgordon.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.jgordon = {
        isNormalUser = true;
        description = "Jess Gordon";
        initialPassword = "test";
        extraGroups = [
          "wheel"
          # Do not add this group if <blank> is not enabled
          (lib.mkIf config.networking.networkmanager.enable "networkmanager")
          (lib.optional config.virtualisation.docker.enable "docker")
        ];
        uid = 1001;
        packages = (with pkgs; [
        ]) ++ (with pkgs-unstable; [
        ]);
    };
  };
}

