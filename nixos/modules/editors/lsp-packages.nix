{ pkgs }:

with pkgs; [
  # languages
  bash-language-server
  typescript-language-server
  python312Packages.python-lsp-server
  rust-analyzer
  gopls
  protols # protobuf
  buf # protobuf

  # configs
  nil
  nixd
  yaml-language-server
  vscode-langservers-extracted

  # misc
  marksman
  # harper # spell check - https://writewithharper.com/ # NOTE: this is lowk buns
]
