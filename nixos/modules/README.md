# Nix Modules

Folder containing custom nix modules

## Caddy

To add new subdomains/services to caddy's proxying, add `(virtualHost config.custom.services.example0)` (where `example0` is the name of the service) to the following

```nix
virtualHosts = lib.mkMerge [
  (virtualHost config.custom.services.example0)
  (virtualHost config.custom.services.example1)
];
```

Ensure that the module you are adding has the following options defined

```nix
options.custom.services.example = {
  enable = lib.mkEnableOption "Enable example.";
  port = lib.mkOption {
    type = lib.types.port;
    default = 4444;
    description = "Port for the example server.";
  };
  subdomain = lib.mkOption {
    type = lib.types.str;
    default = "example";
    description = "The subdomain Caddy should use to reverse proxy.";
  };
};
```
