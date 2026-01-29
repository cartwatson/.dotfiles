{ config, lib, pkgs, pkgs-unstable, settings, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.tailscale;
in
{
  options.custom.services.tailscale = {
    enable = lib.mkEnableOption "Enable tailscale";
    ssh.enable = lib.mkEnableOption "Enable ssh over tailscale (requires authKeyFile to be set)";
    exit-node.enable = lib.mkEnableOption "Advertise machine as exit node";
    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to auth file";
    };
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
    proxy = {
      enable = lib.mkEnableOption "Enable proxy";
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "ts";
        description = "The subdomain Caddy should use to reverse proxy.";
      };
      internal = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Should the proxy host this service internally or externally.";
      };
      auth = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Should the proxy require auth to access this service.";
      };
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
        port = cfg.port;
        openFirewall = true;
        permitCertUid = if baseCfg.caddy.enable then "caddy" else null;
        authKeyFile = cfg.authKeyFile;
        # only works if authkeyfile is provided
        extraUpFlags = if (cfg.authKeyFile != null && cfg.ssh.enable) then [ "--ssh" ] else [ ];
        extraSetFlags = if cfg.exit-node.enable then [ "--advertise-exit-node" ] else [ ];
      };
    })

    (lib.mkIf cfg.server {
      services.headscale = {
        enable = true;
        address = "0.0.0.0";
        port = cfg.port;
        settings = {
          server_url = "https://${cfg.proxy.subdomain}.${settings.domainName}:443"; # 443 as this is for client auth
          dns = {
            magic_dns = true;
            base_domain = "${cfg.proxy.subdomain}.${settings.domainName}";
          };
          # disable headscale tls, use caddy
          tls_cert_path = null;
          tls_key_path = null;
        };
      };
    })
  ]);
}
