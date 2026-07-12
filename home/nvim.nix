{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ripgrep
    fd
    lua-language-server
    gcc
    tree-sitter
  ];

  xdg.configFile."nvim" = {
    source = ../dotfiles/nvim;
    recursive = true;
  };
}
