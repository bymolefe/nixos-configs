# Integration notes

Everything here was generated based on our conversation, working from the
three files you'd uploaded (`flake.nix`, `configuration.nix`,
`hyprland.nix`) — I don't have your live `home.nix`, `home/bash.nix`,
`home/variables.nix`, or your `modules/` directory contents directly, so
a few things below are filled in from context rather than seen firsthand.
Check the flagged items before you `nixos-rebuild switch`.

## Files in this bundle

| File | Status | Action needed |
|---|---|---|
| `flake.nix` | Replaces yours | Drop in as-is |
| `configuration.nix` | Replaces yours | Drop in as-is |
| `hyprland-system.nix` | **New** | Drop in as-is |
| `home.nix` | Replaces yours | Drop in — but see note below if your real `home.nix` had other content |
| `home/hyprland.nix` | **Replaces** your existing one | Drop in — see the comment inside the file for why |
| `home/bash.nix` | Migrated content | Merge if your real file already has other settings |
| `home/kitty.nix` | **New** | Drop in as-is |
| `home/mpv.nix` | **New** | Drop in as-is |
| `home/rofi.nix` | **New** | Drop in as-is |
| `home/waybar.nix` | **New** | Drop in as-is |
| `home/nvim.nix` | **New** | Drop in as-is |
| `home/scripts.nix` | **New** | Drop in as-is |
| `home/variables.nix` | **Not included** | Your existing file is untouched — nothing in our conversation required changing it |

## Manual steps required (things I can't do without your actual files)

1. **Rename `modules/` → `dotfiles/`** in your real repo
   (`git mv modules dotfiles`, or plain `mv` if it's not tracked yet).
   Every `source = ../dotfiles/...` path in this bundle assumes the new
   name.
2. **Check `dotfiles/hypr` actually exists.** Your tree listing showed
   `kitty`, `mpv`, `nvim`, `rofi`, `scripts`, `waybar` under `modules/` —
   no `hypr` folder was visible. `home/hyprland.nix` assumes your real
   Hyprland config will live at `dotfiles/hypr` after the rename. If it's
   somewhere else (or still needs to be created/moved there), update the
   `source` path in that file.
3. **Merge, don't blindly overwrite, `home.nix` and `home/bash.nix`** if
   your real versions already have content beyond what's shown here —
   I only had visibility into what we discussed in this conversation
   (the `programs.bash` block from `configuration.nix`), not whatever
   else may already be in your real `home/bash.nix`.
4. **`home/variables.nix` is left completely alone.** I never saw its
   contents, so there's nothing to merge — it should keep working exactly
   as it did before, since it's just added to `home.nix`'s `imports`
   list unchanged.

## What actually changed, in one paragraph

`programs.hyprland` (the system-level "install and allow launching
Hyprland" switch) moved out of `configuration.nix` into its own
top-level file, `hyprland-system.nix`, referenced directly in
`flake.nix`'s `modules` list — it was never a home-manager option, so it
can't live under `home-manager.users.soul`. `programs.bash` moved from
system-level (`configuration.nix`) to user-level (`home/bash.nix`), since
this is a single-user machine and shell config is personal, not
machine-wide. Six new `home/*.nix` files were added, each doing exactly
one thing: `xdg.configFile` (or `home.file` for the script) pointing at
the matching folder under `dotfiles/`, so your existing configs get
placed into `~/.config/...` unmodified rather than being rewritten as Nix
attributes.

## After dropping these in

```bash
sudo nixos-rebuild switch --flake .#ad-astra
```

If it fails, the error will usually name the exact file and option —
that's the module system telling you which piece doesn't match what it
expected, same as we've walked through throughout this conversation.
