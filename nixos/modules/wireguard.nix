{ config, lib, pkgs, ... }:

let
  hostIPs = [
    {
      name = "jupiter";
      publicKey = "0nQwEvjz/QhP6vf2mVSc4v5MTAgwc5RsBulbAbIPviM=";
      allowedIPs = [ "10.100.0.2/32" ];
    }
    {
      name = "orion";
      publicKey = "";
      allowedIPs = [ "10.100.0.3/32" ];
    }
    {
      name = "eclipse";
      publicKey = "";
      allowedIPs = [ "10.100.0.4/32" ];
    }
    {
      name = "mars";
      publicKey = "";
      allowedIPs = [ "10.100.0.5/32" ];
    }
  ];
  server = {
    publickey = "TXILf6l6hY6Y/UugxgwW8PSurv1HxOP/Gnql6desb0k=";
    ip = "10.100.0.1";
  };
  cfg = config.custom.services.wireguard;
in
{
  options.custom.services.wireguard = {
    enable = lib.mkEnableOption "Enable Wireguard.";
    server = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Setup Wireguard as a server, false (default) is a client setup";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 51820;
      description = "Port for Wireguard.";
    };
    interfaceInternal = lib.mkOption {
      type = lib.types.str;
      default = "wireguard0";
      description = "The internal interface Wireguard will use.";
    };
    serverEndpoint = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.subdomain}.${config.custom.services.caddy.domain}";
      description = "Public IP or hostname of the WireGuard server. (client only)";
    };
    clientIP = lib.mkOption {
      type = lib.types.str;
      default = "10.100.0.2";
      description = "The Wireguard IP of the client. (client only)";
    };
    interfaceExternal = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
      description = "The External interface Wireguard will use. (server only)";
    };
    privateKey = lib.mkOption {
      type = lib.types.str;
      default = "/etc/wireguard/private.key";
      description = "The path to the private key Wireguard will use. (server only)";
    };
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "vpn";
      description = "The subdomain Caddy should use to reverse proxy. (server only)";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # shared settings between client and server
    {
      environment.systemPackages = with pkgs; [ wireguard-tools ];
      networking.firewall.allowedUDPPorts = [ cfg.port ];
      networking.wireguard.enable = true;

      networking.wireguard.interfaces.${cfg.interfaceInternal} = {
        listenPort = cfg.port;
        privateKeyFile = cfg.privateKey;
        generatePrivateKeyFile = true;
      };
    }

    # server
    (lib.mkIf cfg.server {
      networking.nat.enable = true;
      networking.nat.externalInterface = cfg.interfaceExternal;
      networking.nat.internalInterfaces = [ cfg.interfaceInternal ];

      networking.wireguard.interfaces.${cfg.interfaceInternal} = {
        ips = [ "${toString server.ip}/24" ];

        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${cfg.interfaceExternal} -j MASQUERADE
        '';
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${cfg.interfaceExternal} -j MASQUERADE
        '';

        peers = hostIPs;
      };
    })

    # client
    (lib.mkIf (!cfg.server) {
      networking.wireguard.interfaces.${cfg.interfaceInternal} = {
        ips = [ "${toString cfg.clientIP}/24" ];

        peers = [
          {
            publicKey = server.publickey;
            allowedIPs = [ "0.0.0.0/0" ]; # push all traffic out
            # endpoint = "${toString cfg.serverEndpoint}:${toString cfg.port}";
            endpoint = "${toString cfg.serverEndpoint}";
            persistentKeepalive = 25;
          }
        ];
      };
    })
  ]);
}
