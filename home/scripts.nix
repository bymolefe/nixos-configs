{ ... }:
{
  home.file = {
    ".local/scripts/utils/log" = {
      source = ../dotfiles/scripts/utils/log;
      executable = true;
    };

    ".local/bin/screenshot.sh" = {
      source = ../dotfiles/scripts/screenshot.sh;
      executable = true;
    };
  };
  home.sessionPath = [ "$HOME/.local/bin" ];
}
