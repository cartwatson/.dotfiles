{ config, lib, pkgs, pkgs-unstable, ... }:

{
  options.custom.services.helix = {
    enable = lib.mkEnableOption "Enable Helix and LSPs.";
  };

  config = lib.mkIf config.custom.services.helix.enable {
    environment.systemPackages = (with pkgs-unstable; [
      helix
    ]) ++ (with pkgs; [
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
  };
}
