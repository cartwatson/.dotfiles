# Nix Modules

Folder containing custom nix modules

## Headscale

### Add host

1. Enable custom tailscale module
1. On new client run `sudo tailscale up --login-server "https://ts.jjwatson.dev"`
   - on mobile make sure to use chrome instead of safari
1. Copy the last section of the url
1. Run `sudo headscale nodes register --user <user> --key <copied section of url>`

## Caddy

To add new subdomains/services to caddy's reverse proxy list, add `(virtualHost config.custom.services.example0)` (where `example0` is the name of the service) to the following

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
