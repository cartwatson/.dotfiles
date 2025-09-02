{ config, lib, pkgs, pkgs-unstable, ... }:

{
  options.custom.services.caddy = {
    enable = lib.mkEnableOption "Enable Caddy.";
  };

  config = lib.mkIf config.custom.services.caddy.enable {
    services.caddy = {
      enable = true;
      virtualHosts."jjwatson.dev".extraConfig = ''
        reverse_proxy :8001
      '';
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}

