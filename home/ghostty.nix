{ ... }:
{
  xdg.configFile."ghostty" = {
    source = ../dotfiles/ghostty;
    recursive = true;
  };
}
