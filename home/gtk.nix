{ ... }:
{
  xdg.configFile."gtk-3.0" = {
    source = ../dotfiles/gtk-3.0;
    recursive = true;
  };

  xdg.configFile."gtk-4.0" = {
    source = ../dotfiles/gtk-4.0;
    recursive = true;
  };
}
