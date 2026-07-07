{ config, lib, pkgs, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPkgs = true;

  home-manager.users.soul = { pkgs, ... }: {
    imports = [
      ./home/bash.nix
      ./home/variables.nix
      ./home/hyprland.nix
      ./home/git.nix
    ];
    home.stateVersion = "26.05";
  };
}
