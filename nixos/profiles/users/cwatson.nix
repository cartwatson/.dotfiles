{ config, lib, pkgs, pkgs-unstable, ... }:

{
  options.custom.users.cwatson = {
    enable = lib.mkEnableOption "Create user 'cwatson'";
  };

  config = lib.mkIf config.users.cwatson.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.cwatson = {
        isNormalUser = true;
        description = "Carter Watson";
        initialPassword = "test";
        extraGroups = [
          "wheel"
          # Do not add this group if <blank> is not enabled
          (lib.mkIf config.networking.networkmanager.enable "networkmanager")
          (lib.optional config.virtualisation.docker.enable "docker")
        ];
        uid = 1000;
        packages = (with pkgs; [
          element-desktop
          discord
          slack
          drawing # MS Paint alternative
        ]) ++ (with pkgs-unstable; [
        ]);
    };
  };
}

