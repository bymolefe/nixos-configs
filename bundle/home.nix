# Home-manager hub — this is a NixOS module (listed in flake.nix's
# top-level `modules`), and its only job is to turn home-manager on and
# point it at the per-program files that make up `soul`'s actual
# environment. Nothing program-specific belongs directly in this file.
{ config, lib, pkgs, inputs, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.soul = {
    imports = [
      ./home/bash.nix
      ./home/variables.nix
      ./home/hyprland.nix
      ./home/kitty.nix
      ./home/mpv.nix
      ./home/nvim.nix
      ./home/rofi.nix
      ./home/waybar.nix
      ./home/scripts.nix
    ];

    home.stateVersion = "26.05";
  };
}
