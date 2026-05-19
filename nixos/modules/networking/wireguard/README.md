# WireGuard

Custom WireGuard module.

## Oort

Mesh network where all hosts connect through a hub node (a host with a public endpoint).
Traffic between non-hub hosts is relayed through the hub.

### Enable on a host

Requires `custom.secrets.enable = true` on the host.

```nix
sops.secrets.wg-private-key = {
  sopsFile = ./secrets/wireguard.yaml;
};

custom.services.wireguard = {
  enable = true;
  oort = {
    enable = true;
    privateKeyFile = config.sops.secrets.wg-private-key.path;
  };
};
```

### Enable on the hub node

The hub node needs a port forwarded through the router (`51820`) and IP forwarding enabled.

```nix
custom.services.wireguard.oort.hubNode.enable = true;
```

### Add a new host

1. Open shell with `wg`, `nix-shell -p wireguard-tools`
1. Generate a keypair: `wg genkey | tee /dev/stderr | wg pubkey` (first line is private key, second is public key)
2. Add the host, its address, and its public key to `./oort-peers.nix`
3. Put the private key in `~/.dotfiles/nixos/hosts/secrets/secrets.yaml` under wireguard/networkname
5. Enable oort in the host config (see above)
6. Rebuild all hosts so they pick up the new peer
