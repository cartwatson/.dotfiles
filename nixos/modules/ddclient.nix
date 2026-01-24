{ config, lib, settings, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.ddclient;
in
{
  options.custom.services.ddclient = {
    enable = lib.mkEnableOption "Enable ddclient.";
    cloudfareApiKeyPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Cloudflare API token file location";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Domain & Zone name";
    };
  };

  # DOCS: https://github.com/ddclient/ddclient/blob/50e8d2ed0072462dd1a00268593242d7ae809531/ddclient.in#L5846-L5888
  # EXAMPLE: https://github.com/JayRovacsek/nix-config/blob/27ef4a04a615a3d61f93abd92902fb3cb39f3838/modules/ddclient/default.nix
  config = lib.mkIf cfg.enable {
    services.ddclient = {
      enable = true;
      interval = "5min";
      protocol = "cloudflare";
      username = "token";
      passwordFile = cfg.cloudfareApiKeyPath;
      domains = [ cfg.domainName ];
      zone = cfg.domainName;
      verbose = true;
    };
  };
}
