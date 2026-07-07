{ ... }:
{
  home.file.".local/bin/screenshot.sh" = {
    source = ../dotfiles/scripts/screenshot.sh;
    executable = true;
  };

  home.sessionPath = [ "$HOME/.local/bin" ];
}
