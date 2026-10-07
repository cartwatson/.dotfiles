{ config, lib, ... }:
let
  baseCfg = config.pillar.services;
  cfg = baseCfg.prometheus.node;
in
{
  options.pillar.services.prometheus.node = {
    enable = lib.mkEnableOption "Enable prometheus.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9000;
      description = "Port for the prometheus node.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      port = cfg.port;
      # For the list of available collectors, run, depending on your install:
      # nix run nixpkgs#prometheus-node-exporter -- --help
      enabledCollectors = [
        "ethtool"
        "softirqs"
        "systemd"
        "tcpstat"
      ];
      # You can pass extra options to the exporter using `extraFlags`
      extraFlags = [ "--collector.ntp.protocol-version=4" "--no-collector.mdadm" ];
    };
  };
}
