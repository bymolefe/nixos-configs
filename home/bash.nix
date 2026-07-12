{ pkgs, ... }: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export PROMPT_DIRTRIM=2
      export EDITOR="codium"
      community=github:the-nix-way/dev-templates
      official=github:NixOS/templates

      __git_status_ps1() {
        local branch ahead behind staged modified untracked stashed conflicts
        local git_dir

        git_dir=$(git rev-parse --git-dir 2>/dev/null) || return
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        [ -z "$branch" ] && return

        local status
        status=$(git status --porcelain=v2 --branch 2>/dev/null)

        ahead=$(echo "$status" | grep -oP '(?<=ahead )\d+')
        behind=$(echo "$status" | grep -oP '(?<=behind )\d+')

        staged=$(echo "$status" | grep -c '^1 [MADRC]')
        modified=$(echo "$status" | grep -c '^1 .[MADRC]')
        untracked=$(echo "$status" | grep -c '^?')
        conflicts=$(echo "$status" | grep -c '^u')
        stashed=$(git stash list 2>/dev/null | wc -l)

        local out=" ''${branch}"
        [ -n "$ahead" ] && [ "$ahead" -gt 0 ] && out+=" ''${ahead}"
        [ -n "$behind" ] && [ "$behind" -gt 0 ] && out+=" ''${behind}"
        [ "$staged" -gt 0 ] && out+=" ''${staged}"
        [ "$modified" -gt 0 ] && out+=" ✎''${modified}"
        [ "$untracked" -gt 0 ] && out+=" ''${untracked}"
        [ "$conflicts" -gt 0 ] && out+=" ✘''${conflicts}"
        [ "$stashed" -gt 0 ] && out+=" ''${stashed}"

        echo "$out"
      }

      __venv_ps1() {
        if [ -n "$VIRTUAL_ENV" ]; then
          echo "  ''${VIRTUAL_ENV##*/}"
        fi
      }

      __set_ps1() {
        local exit=$?
        local blue="\[\033[1;34m\]"
        local purple="\[\033[1;35m\]"
        local yellow="\[\033[1;33m\]"
        local red="\[\033[1;31m\]"
        local reset="\[\033[0m\]"
        local prompt_char="❯"
        [ $exit -ne 0 ] && prompt_char="''${red}❯''${reset}" || prompt_char="\[\033[1;32m\]❯''${reset}"

        PS1="''${blue}\u in \w''${reset}"
        PS1+="''${purple}$(__git_status_ps1)''${reset}"
        PS1+="''${yellow}$(__venv_ps1)''${reset}"
        PS1+="\n''${prompt_char} "
      }

      PROMPT_COMMAND="__set_ps1''${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    '';
    shellAliases = {
      code = "codium";
      ls = "ls -l --color=auto";
    };
  };
}
