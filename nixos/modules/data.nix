{ config, lib, ... }:

let
  data = config.pillar.data;
  forwarded_services_subdomain_collision_check = forwardedServices:
    (subdomains: subdomains == lib.lists.unique subdomains) # check all subdomains are unique
      (lib.mapAttrsToList (_: svc: svc.proxy.subdomain) # build list of subdomains
        (lib.filterAttrs (_: svc: svc.proxy.enable) forwardedServices)); # filter to enabled services only
in
{
  options.pillar.data = {
    backupPaths = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Paths to be backed up by backup services (eg Restic).";
    };

    # DOCS:
    # All services requesting reverse proxy MUST implement options that match
    # the below submodule exactly. They must be provided to this data scheme
    # without extra options and with options that strictly match the below
    #
    # NOTE: This submodule only validates form of supplied options and ensures
    # that the supplied options are available
    forwardedServices = lib.mkOption {
      default = { };
      description = "Services to be forwarded by reverse proxy (eg Caddy).";
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          port = lib.mkOption {
            type = lib.types.port;
            description = "The local port the service listens on.";
          };
          proxy = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enable = lib.mkEnableOption "reverse proxy for selected service";
                auth = lib.mkEnableOption "auth from the reverse proxy to access this service.";
                subdomain = lib.mkOption {
                  type = lib.types.str;
                  description = "The subdomain the proxy should use to reverse proxy.";
                };
              };
            };
          };
        };
      });
    };
  };

  config = {
    assertions = [
      {
        assertion = forwarded_services_subdomain_collision_check data.forwardedServices;
        message = "pillar.data.forwardedServices: Services must not share a subdomain.";
      }
    ];
  };
}
