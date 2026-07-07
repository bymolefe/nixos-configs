# Migrated from configuration.nix's system-level `programs.bash`.
# If your existing home/bash.nix already has content, merge this in
# rather than overwriting — this reflects only what was previously in
# configuration.nix.
#
# Note: home-manager's bash module uses `initExtra` (raw bash appended
# to .bashrc for interactive shells) where NixOS used `promptInit` — the
# option name changes between the two module trees even though the
# concept is the same.
{ ... }:
{
  programs.bash = {
    enable = true;
    initExtra = ''
      export PS1="\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w] $ \[\033[0m\]"
    '';
    shellAliases = {
      code = "codium";
      ls = "ls -l";
    };
  };
}
