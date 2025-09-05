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
    {
      environment.systemPackages = (
        lib.optionals cfg.enable (with pkgs; [ tailscale ])
        ++ lib.optionals cfg.server (with pkgs; [ headscale ])
      );
    }

    (lib.mkIf cfg.enable {
      # enable systemd service
      services.tailscale = {
        enable = true;
        interfaceName = "headscale0";
      };
      networking.firewall.allowedUDPPorts = [ cfg.port ];
    })

    (lib.mkIf cfg.server {
      services.headscale = {
        enable = true;
        address = "0.0.0.0";
        port = cfg.port;
        settings = {
          server_url = "https://${cfg.subdomain}.${settings.domainName}:${toString cfg.port}";
          dns = {
            magic_dns = true;
            base_domain = "${cfg.subdomain}.${settings.domainName}";
          };
          # disable headscale tls, use caddy
          tls_cert_path = null;
          tls_key_path = null;
        };
      };
    })
  ]);
}
