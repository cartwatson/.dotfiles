{ config, lib, ... }:
let
  baseCfg = config.pillar.services;
  cfg = baseCfg.prometheus;

  localTarget = lib.optional cfg.node.enable "localhost:${toString cfg.node.port}";
in
{
  options.pillar.services.prometheus = {
    enable = lib.mkEnableOption "Enable prometheus.";
    pollingInterval = lib.mkOption {
      type = lib.types.str;
      default = "10s";
      description = "Interval at which prometheus should poll nodes";
    };
    targets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of additional targets to gather data from, local node is always configured.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "Port for the prometheus server.";
    };
  };

  # https://wiki.nixos.org/wiki/Prometheus
  # https://nixos.org/manual/nixos/stable/#module-services-prometheus-exporters-configuration
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/default.nix
  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      port = cfg.port;
      globalConfig.scrape_interval = cfg.pollingInterval;
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = localTarget ++ cfg.targets;
          }];
        }
      ];
    };
  };
}
