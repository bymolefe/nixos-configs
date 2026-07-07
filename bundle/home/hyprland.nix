# REPLACES your existing home/hyprland.nix.
#
# Your old home/hyprland.nix contained `programs.hyprland = { enable =
# true; ... };` — that's a NixOS-tree option and does not exist inside
# home-manager.users.soul, so it would error if left here. That content
# now lives in ../hyprland-system.nix instead (see that file).
#
# This file's job is purely to place your actual Hyprland config
# (hyprland.conf, any included files) into ~/.config/hypr, unmodified,
# using the same xdg.configFile pattern as the other home/*.nix files.
#
# ASSUMPTION: your real Hyprland config lives at ../dotfiles/hypr.
# Your tree listing didn't show a hypr folder under modules/ — if your
# config lives somewhere else (e.g. still under modules/hyprland), adjust
# the `source` path below to match.
{ ... }:
{
  xdg.configFile."hypr" = {
    source = ../dotfiles/hypr;
    recursive = true;
  };
}
