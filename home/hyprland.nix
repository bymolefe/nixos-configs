{ pkgs, ... }:
{
  xdg.configFile."hypr" = {
    source = ../dotfiles/hypr;
    recursive = true;
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors-white";
    size = 24;
  };
}
