# `recursive = true` links each file individually, leaving ~/.config/nvim
# itself a real, writable directory. Since you've already removed
# lazy-lock.json from dotfiles/nvim, lazy.nvim can freely create and
# rewrite it at runtime without any Nix store permission conflict.
{ ... }:
{
  xdg.configFile."nvim" = {
    source = ../dotfiles/nvim;
    recursive = true;
  };
}
