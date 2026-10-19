{ lib, ... }:
{
  options.pillar.data = {
    backupPaths = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Paths to be backedup by backup services (eg Restic).";
    };
  };
}
