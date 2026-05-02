{ config, lib, pkgs, settings, ... }:

let
  cfg = config.custom.services.wireguard;

  # compute peers
  oort = rec {
    subnet = "10.0.0.0/24";
    peers = import ./oort-peers.nix { inherit settings; };
    otherPeers = lib.filterAttrs (name: _: name != config.networking.hostName) peers;
    self = peers.${config.networking.hostName};
  };
in
{
  options.custom.services.wireguard = {
    enable = lib.mkEnableOption "Enable WireGuard configurations";
    oort = {
      enable = lib.mkEnableOption "Enable OORT network config.";
      privateKeyFile = lib.mkOption {
        type = lib.types.path;
        # default = "/run/secrets/wireguard/oort/${config.networking.hostName}";
        description = "Filepath of private key";
      };
      hubNode.enable = lib.mkEnableOption "Open Firewall and enable ipv4 forwarding at a kernel level";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      ({
        environment.systemPackages = (with pkgs; [
          wireguard-tools # needed for keygen
        ]);
      })

      # OORT -------------------------------------------------------------------
      (lib.mkIf cfg.oort.enable {
        # ----- tests -----
        assertions = [{
            assertion = builtins.hasAttr config.networking.hostName oort.peers;
            message = "Host '${config.networking.hostName}' not found in modules/wireguard/oort-peers.nix";
          }];

        # ---- config -----
        networking.wg-quick.interfaces.oort = {
          # grab address from ./oort-peers.nix
          address = [ "${oort.self.address}/24" ];

          # get private key
          privateKeyFile = cfg.oort.privateKeyFile;

          # dynamic list of peers for all hosts
          # generated from ./oort-peers.nix
          # NOTE: do not include self
          peers = lib.mapAttrsToList (name: peer: {
            # if peer has an endpoint, then allow traffic from the subnet, else assign self IP
            allowedIPs = if peer ? endpoint
              then [ oort.subnet ]
              else [ "${peer.address}/32" ];
            persistentKeepalive = 25;
            publicKey = peer.publicKey;
          # if endpoint is defined, then add it to config, else no action
          } // lib.optionalAttrs (peer ? endpoint) {
            endpoint = peer.endpoint;
          }) oort.otherPeers;
        };

        # DNS, resolve <host>.oort
        networking.extraHosts = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: peer: "${peer.address} ${name}.oort") oort.otherPeers
        );
      })

      (lib.mkIf cfg.oort.hubNode.enable {
        # ----- tests -----
        assertions = [{
          assertion = cfg.oort.hubNode.enable -> cfg.oort.enable;
          message = "wireguard.oort.hubnode.enable requires wireguard.oort.enable";
        }];

        # ---- config -----
        networking.firewall.allowedUDPPorts = [ 51820 ];
        boot.kernel.sysctl."net.ipv4.ip_forward" = "1"; # almost equal to `postUp = "iptables -A FORWARD -i oort -j ACCEPT"`
      })

      # Promised Lan -----------------------------------------------------------
      # TODO: one day
    ]
  );
}
