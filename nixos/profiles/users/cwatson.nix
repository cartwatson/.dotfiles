{ config, lib, pkgs, pkgs-unstable, ... }:

{
  options.custom.users.cwatson = {
    enable = lib.mkEnableOption "Create user 'cwatson'";
  };

  config = lib.mkIf config.custom.users.cwatson.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.cwatson = {
      uid = 1000;
      isNormalUser = true;
      description = "Carter Watson";
      extraGroups = [
        "wheel"
        # Do not add this group if <blank> is not enabled
        (lib.mkIf config.networking.networkmanager.enable "networkmanager")
        # (lib.optional config.virtualisation.docker.enable "docker")
      ];
      packages = (with pkgs; [
        caligula # ISO Burner
        speedtest-go
      ] ++ (lib.lists.optionals config.custom.services.gnome.enable [ # only add GUI apps if using gnome
        element-desktop
        discord
        slack
        drawing # MS Paint alternative
      ])) ++ (with pkgs-unstable; [
      ]);
    };
  };
}

