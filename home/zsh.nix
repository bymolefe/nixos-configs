{ ... }:
{
  programs.zsh = {
    enable = true;
    shellAliases = {
      cc = "claude";
      ff = "fastfetch";
      code = "codium";
      ls = "ls -l --color=auto";
      rebuild = "sudo nixos-rebuild";
      tp = "tmux new-session -s \"$(basename $(pwd))\"";
      tl = "tmux list-sessions";
      ta = "tmux attach-session -t";
      tn = "tmux new-session -s";
      tk = "tmux kill-session -t";
      ts = "tmux switch-client -t";
    };
    initContent = ''
      export EDITOR="nvim"
      export VISUAL="nvim"
      export para="/mnt/data/side_a"
      export soul="/mnt/data/side_b"
      export area="$para/area"
      export project="$para/project"
      export resource="$para/resource"
      export archive="$para/archive"
      export dev="$area/playground"
      community=github:the-nix-way/dev-templates
      official=github:NixOS/templates

      # Completion
      autoload -Uz compinit && compinit
      setopt MENU_COMPLETE       # tab cycles through menu
      setopt AUTO_LIST           # list choices on ambiguous completion
      setopt COMPLETE_IN_WORD    # complete from cursor position
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive

      # Word navigation
      bindkey '\e[1;5D' backward-word       # Ctrl+Left
      bindkey '\e[1;5C' forward-word        # Ctrl+Right
      bindkey '\e[1;3D' backward-word       # Alt+Left
      bindkey '\e[1;3C' forward-word        # Alt+Right
      bindkey '^H'      backward-kill-word  # Ctrl+Backspace
      bindkey '\e[3;5~' kill-word           # Ctrl+Delete

      autoload -Uz add-zsh-hook

      __git_status_ps1() {
        local git_dir branch git_status ahead behind staged modified untracked conflicts stashed out

        git_dir=$(git rev-parse --git-dir 2>/dev/null) || return
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        [[ -z "$branch" ]] && return

        git_status=$(git status --porcelain=v2 --branch 2>/dev/null)

        ahead=$(echo "$git_status" | grep -oP '(?<=ahead )\d+')
        behind=$(echo "$git_status" | grep -oP '(?<=behind )\d+')
        staged=$(echo "$git_status" | grep -c '^1 [MADRC]')
        modified=$(echo "$git_status" | grep -c '^1 .[MADRC]')
        untracked=$(echo "$git_status" | grep -c '^?')
        conflicts=$(echo "$git_status" | grep -c '^u')
        stashed=$(git stash list 2>/dev/null | wc -l)

        local icon=$''
        out=" ''${icon} ''${branch}"
        [[ -n "$ahead"   && "$ahead"   -gt 0 ]] && out+=" ⇡''${ahead}"
        [[ -n "$behind"  && "$behind"  -gt 0 ]] && out+=" ⇣''${behind}"
        [[ "$staged"    -gt 0 ]] && out+=" ●''${staged}"
        [[ "$modified"  -gt 0 ]] && out+=" ✚''${modified}"
        [[ "$untracked" -gt 0 ]] && out+=" …''${untracked}"
        [[ "$conflicts" -gt 0 ]] && out+=" ✖''${conflicts}"
        [[ "$stashed"   -gt 0 ]] && out+=" ⚑''${stashed}"

        echo "$out"
      }

      __venv_ps1() {
        [[ -n "$VIRTUAL_ENV" ]] && echo "  ''${VIRTUAL_ENV##*/}"
      }

      __set_prompt() {
        local exit=$?
        local prompt_char
        if [[ $exit -ne 0 ]]; then
          prompt_char="%F{red}❯%f"
        else
          prompt_char="%F{green}❯%f"
        fi
        PROMPT="%B%F{blue}%n in %2~%f%b%F{magenta}$(__git_status_ps1)%f%F{yellow}$(__venv_ps1)%f
''${prompt_char} "
      }

      add-zsh-hook precmd __set_prompt
    '';
  };
}
