# System-level Hyprland switch — NOT a home-manager module.
#
# This lives in flake.nix's top-level `modules` list, alongside
# configuration.nix and hardware-configuration.nix. Its only job is to
# install the Hyprland package and wire up the login session so `ly`
# (your display manager) can launch it.
#
# Your actual Hyprland *config* — binds, monitors, exec-once, window
# rules — lives separately, at the home-manager level, in
# home/hyprland.nix, symlinked in from dotfiles/hypr.
#
# This is the content that was previously inline in configuration.nix,
# and is identical to the hyprland.nix you uploaded earlier — moved here
# because `programs.hyprland` is a NixOS-tree option and cannot live
# inside `home-manager.users.soul.imports`.
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
}
