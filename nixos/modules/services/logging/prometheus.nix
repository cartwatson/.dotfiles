{ config, lib, pkgs, ... }:
let
  baseCfg = config.pillar.services;
  cfg = baseCfg.prometheus;
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
      # TODO: is there a better way to do this?
      default = [
        "localhost:${toString config.pillar.services.prometheus.node.port}"
      ];
      description = "List of targets to gather data from";
    };
  };

  # https://wiki.nixos.org/wiki/Prometheus
  # https://nixos.org/manual/nixos/stable/#module-services-prometheus-exporters-configuration
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/default.nix
  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      globalConfig.scrape_interval = cfg.pollingInterval;
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{ targets = cfg.targets; }];
        }
      ];
    };
  };
}
