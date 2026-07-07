{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hosts/ad-astra/hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "ad-astra"; 

  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Africa/Maseru";

  services.displayManager.ly.enable = true;

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  security.polkit.enable = true;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };

  xdg.portal.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    para = " /mnt/data/side_a";
    soul = " /mnt/data/side_b";
    dev= " $area/playground";
    project = "$para/project";
    area = "$para/area";
    resource = "$para/resource";
    archive = "$para/archive";
  };

  users.users.soul = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ]; 
    packages = with pkgs; [
      neovim
      cmatrix
      fastfetch
      ghostty
      hyprlock
      rofi
      mpv
    ];
  };

  environment.systemPackages = with pkgs; [
    tree
    bat
    btop
    hyprshot
    wl-clipboard
    satty
    direnv
    nwg-look
    brightnessctl
    zip
    unzip
    brave
    vscodium
    awww
    wget
    spotify
    nautilus
    git
    wget
    papirus-icon-theme
    proton-vpn
    capitaine-cursors
    dnsmasq
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  networking.firewall.enable = false;
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  networking.firewall.checkReversePath = false;

  nix.gc = {
    automatic = true;
    dates = "19:00";
    options = "--delete-older-than 3d";
  };

  environment.variables = {
    XCURSOR_THEME = "Capitaine Cursors";
    XCURSOR_SIZE = "24";
  };

  programs.dconf.enable = true;

  systemd.user.services.cursor-theme-fix = {
    description = "Force cursor theme for GNOME/GTK apps";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.gsettings-desktop-schemas}/bin/gsettings set org.gnome.desktop.interface cursor-theme 'Capitaine Cursors'";
    };
  };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/b86e8ed0-05aa-4244-ad8f-8538a1852608";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
 
  system.stateVersion = "26.05"; 
}
