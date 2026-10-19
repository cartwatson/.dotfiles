{ lib, ... }:
{
  options.pillar.data = {
    backupPaths = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Paths to be backedup by backup services (eg Restic).";
    };
    forwardedServices = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
      default = [ ];
      description = "Services to be forwarded by reverse proxy (eg Caddy).";
    };
    # forwardedServices = lib.mkOption {
    #   default = {};
    #   description = "Services to be forwarded by reverse proxy (eg Caddy).";
    #   type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
    #     options = {
    #     };
    #   }));
    # };
  };
}
