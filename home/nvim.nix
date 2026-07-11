{ pkgs, ... }:
{
  home.packages = with pkgs; [ ripgrep fd ];

  xdg.configFile."nvim" = {
    source = ../dotfiles/nvim;
    recursive = true;
  };
}
