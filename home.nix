{ config, lib, pkgs, inputs, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bak";
  
  home-manager.users.soul = {
    imports = [
      ./home/bash.nix
      ./home/ghostty.nix
      ./home/variables.nix
      ./home/hyprland.nix
      ./home/kitty.nix
      ./home/mpv.nix
      ./home/nvim.nix
      ./home/tmux.nix
      #./home/rofi.nix
      #./home/waybar.nix
      ./home/scripts.nix
      ./home/theme.nix
      ./home/fastfetch.nix
      ./home/editor.nix
    ];

    home.stateVersion = "26.05";
  };
}
