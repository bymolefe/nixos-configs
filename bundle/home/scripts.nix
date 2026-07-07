# Scripts aren't program config — they're executables meant to be run,
# so this uses `home.file` targeting ~/.local/bin, not `xdg.configFile`
# targeting ~/.config. `executable = true` preserves the +x bit through
# the Nix store copy.
{ ... }:
{
  home.file.".local/bin/screenshot.sh" = {
    source = ../dotfiles/scripts/screenshot.sh;
    executable = true;
  };

  home.sessionPath = [ "$HOME/.local/bin" ];
}
