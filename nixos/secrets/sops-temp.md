1. Widen the sops creation rule so it covers any file under `secrets/`, not just the one:
In `.sops.yaml`, change:
`path_regex: secrets/secrets.yaml`
to:
`path_regex: secrets/.*\.yaml$`

2. Create the new encrypted file. Don't create it as a plain file — let sops create it so it's encrypted from the start:
`sops secrets/oauth2-proxy.yaml`
This opens your editor with an empty doc. It'll match the widened rule and encrypt with the same age keys as your existing secrets on save.

3. Pick key names inside that file, following the existing namespace/key convention (like `api_tokens/github_readonly`):
```yaml
oauth2-proxy:
  client_secret: <paste GitHub OAuth client secret>
  cookie_secret: <paste generated value>
  authorized_emails: |
    you@example.com
    spouse@example.com
```
For `cookie_secret`, run the dd/base64 command in the comment in `oauth2-proxy.nix` and paste its output here.

4. Register the secrets in `server.nix`, pointing each at the new file since it's not the default:
```nix
sops.secrets = {
  # ...existing entries...
  "oauth2-proxy/client_secret" = { sopsFile = ../secrets/oauth2-proxy.yaml; };
  "oauth2-proxy/cookie_secret" = { sopsFile = ../secrets/oauth2-proxy.yaml; };
  "oauth2-proxy/authorized_emails" = { sopsFile = ../secrets/oauth2-proxy.yaml; };
};
```

5. Wire the runtime paths into `pillar.services.oauth2-proxy.setup`, same convention as `authKeyFile`/`cloudflareApiKeyPath` elsewhere in `server.nix` (plain `/run/secrets/...` strings):
```nix
setup = {
  clientID = "Ov23liGmeEEYor02mUtZ";
  clientSecretFile = "/run/secrets/oauth2-proxy/client_secret";
  cookieSecretFile = "/run/secrets/oauth2-proxy/cookie_secret";
  authorizedEmailsFile = "/run/secrets/oauth2-proxy/authorized_emails";
};
```

6. Rebuild/switch on a machine whose age key is listed in `.sops.yaml`, then confirm the files actually materialized: `ls -la /run/secrets/oauth2-proxy/`

To edit these later, always go through sops secrets/oauth2-proxy.yaml — never open the encrypted file directly in a plain editor.

