{ config, lib, pkgs, inputs, ... }:
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
  programs.nm-applet.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Africa/Maseru";

  services.displayManager.ly.enable = true;
  services.postgresql.enable = true;
  services.pgadmin = {
    enable = true;
    # CHANGE THIS TO YOUR EMAIL
    initialEmail = "you@example.com";
    # CREATE FILE WITH TIGHT PERMISSIONS (600) AND PLACE PASSWORD IN THERE
    initialPasswordFile = "/etc/pgadmin/pgadmin-password";
  };
  # services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.ly.enableGnomeKeyring = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.NetworkManager.") === 0 &&
          subject.user === "soul") {
        return polkit.Result.YES;
      }
    });
  '';

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
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "libvirtd" ]; 
    packages = with pkgs; [
      neovim
      unimatrix
      fastfetch
      ghostty
      hyprlock
      rofi
      mpv
      tmux
    ];
  };

  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    claude-code
    git
    unzip
    zip
    awww
    wget
    satty
    dnsmasq
    wl-clipboard
    brightnessctl
    hyprshot
    dunst
    libnotify
    vscodium
    proton-vpn
    spotify
    thunar
    nwg-look
    tree
    bat
    btop
    papirus-icon-theme
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  networking.firewall.checkReversePath = false;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  programs.zsh.enable = true;
  programs.dconf.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/b86e8ed0-05aa-4244-ad8f-8538a1852608";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
 
  system.stateVersion = "26.05"; 
}
