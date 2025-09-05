{ config, lib, pkgs, pkgs-unstable, settings, ... }:

let
  cfg = config.custom.services.tailscale;
in
{
  options.custom.services.tailscale = {
    enable = lib.mkEnableOption "Enable tailscale.";
    server = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Setup Tailscale (Headscale) as a server, false (default) is a client setup";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 41641;
      description = "Port for Headscale.";
    };
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "ts";
      description = "The subdomain Caddy should use to reverse proxy.";
    };
  };

  config = (lib.mkMerge [
    lib.mkIf cfg.enable {
      # allow users to use `tailscale` command
      environment.systemPackages = (with pkgs-unstable; [
        tailscale
      ]);

      # enable systemd service
      services.tailscale = {
        enable = true;
        interfaceName = "headscale0";
      };

      networking.firewall.allowedUDPPorts = [ cfg.port ];
    }

    lib.mkIf cfg.server {
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = cfg.port;
        server_url = "https://${cfg.subdomain}.${settings.domainName}:${cfg.port}";
        dns.base_domain = "${cfg.subdomain}.${settings.domainName}";
      };

      environment.systemPackages = (with pkgs; [
        headscale
      ]);
    }
  ]);
}
