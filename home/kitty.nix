{ ... }:
{
  xdg.configFile."kitty" = {
    source = ../dotfiles/kitty;
    recursive = true;
  };
}
