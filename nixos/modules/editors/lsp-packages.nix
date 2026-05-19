{ pkgs }:

with pkgs; [
  # languages
  bash-language-server
  typescript-language-server
  python312Packages.python-lsp-server
  rust-analyzer
  gopls
  # configs
  nil
  yaml-language-server
  vscode-langservers-extracted
  # misc
  marksman
]
