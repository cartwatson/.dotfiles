{ config, lib, pkgs, ... }:

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
      ] ++ (lib.optional config.networking.networkmanager.enable "networkmanager");

      packages = (with pkgs; [
        caligula # ISO Burner
        speedtest-go
      ] ++ (lib.lists.optionals config.custom.services.gnome.enable [ # only add GUI apps if using gnome
        element-desktop
        discord
        slack
        drawing # MS Paint alternative
        flameshot # TODO: find a way to deterministically config this
      ]));
    };
  };
}

