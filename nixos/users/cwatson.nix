{ config, lib, pkgs, ... }:

{
  options.pillar.users.cwatson = {
    enable = lib.mkEnableOption "Create user 'cwatson'";
  };

  config = lib.mkIf config.pillar.users.cwatson.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.cwatson = {
      isNormalUser = true;
      initialPassword = "changeme";
      description = "Carter Watson";
      extraGroups = [
        "wheel"
      ] ++ (lib.optional config.networking.networkmanager.enable "networkmanager");

      packages = (with pkgs; [
        caligula # ISO Burner
        speedtest-go
      ] ++ (lib.lists.optionals config.pillar.profiles.desktop.enable [ # GUI apps
        element-desktop
        discord
        slack
        drawing # MS Paint alternative
        flameshot # TODO: find a way to deterministically config this
      ]));
    };
  };
}

