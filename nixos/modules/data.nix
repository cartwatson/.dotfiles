{ lib, ... }:
{
  options.pillar.data = {
    backupPaths = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Paths to be backedup by backup services (eg Restic).";
    };
    forwardedServices = lib.mkOption {
      default = { };
      description = "Services to be forwarded by reverse proxy (eg Caddy).";
      # NOTE: this submodule exists **ONLY** to validate form
      # modules MUST implment options themselves
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          port = lib.mkOption {
            type = lib.types.port;
            description = "The local port the service listens on.";
          };
          proxy = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enable = lib.mkEnableOption "Enable proxy";
                auth = lib.mkEnableOption "Should the proxy require auth to access this service.";
                subdomain = lib.mkOption {
                  type = lib.types.str;
                  description = "The subdomain the proxy should use to reverse proxy.";
                };
                # TODO: make this do something in ./services/caddy.nix
                internal = lib.mkEnableOption "Should the proxy host this service internally or externally.";
              };
            };
          };
        };
      });
    };
  };
}
