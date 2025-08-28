{ config, lib, pkgs, pkgs-unstable, ... }:

{
  options.custom.services.helix = {
    enable = lib.mkEnableOption "Enable Helix and LSPs.";
    LSPs = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = (with pkgs; [
        # languages
        bash-language-server                    # bash... duh
        python312Packages.python-lsp-server     # python
        rust-analyzer                           # rust
        gopls                                   # go
        # configs
        nil                                     # nix
        yaml-language-server                    # yaml
        vscode-langservers-extracted            # html, css, json
        # misc
        marksman                                # markdown
      ]);
      description = "Additional LSP servers.";
    };
  };

  config = lib.mkIf config.custom.services.helix.enable {
    environment.systemPackages = (with pkgs-unstable; [
      helix
    ]);
  };
}
