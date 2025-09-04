{ config, lib, pkgs, pkgs-unstable, ... }:

{
  options.custom.services.tailscale = {
    enable = lib.mkEnableOption "Enable tailscale.";
  };

  config = lib.mkIf config.custom.services.tailscale.enable {
    # allow users to use `tailscale` command
    environment.systemPackages = (with pkgs-unstable; [
      tailscale
    ]);

    # enable systemd service
    services.tailscale.enable = true;
  };
}
