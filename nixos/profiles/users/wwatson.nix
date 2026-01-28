{ config, lib, pkgs, pkgs-unstable, ... }:

{
  options.custom.users.wwatson = {
    enable = lib.mkEnableOption "Create user 'wwatson'";
  };

  config = lib.mkIf config.custom.users.wwatson.enable {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.wwatson = {
      uid = 1002;
      isNormalUser = true;
      description = "William Watson";
      extraGroups = [
        "wheel"
        # Do not add this group if <blank> is not enabled
        (lib.mkIf config.networking.networkmanager.enable "networkmanager")
      ];

      packages = (with pkgs; [
      ] ++ (lib.lists.optionals config.custom.services.gnome.enable [ # only add GUI apps if using gnome
        discord
      ])) ++ (with pkgs-unstable; [
      ]);
    };
  };
}

