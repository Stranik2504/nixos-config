{ config, lib, pkgs, vars, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./docker.nix
      ./hardware.nix
      ./login.nix
      ./portals.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = vars.HOSTNAME;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Moscow";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  services.xserver.enable = true;

  # natural scroll
  # services.xserver.libinput.naturalScrolling
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  environment.systemPackages = with pkgs; [
    alsa-firmware
    sof-firmware
  ];

  users.users.${vars.USER} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  networking.firewall.enable = false;

  # Dont touch
  system.stateVersion = "24.05";

  nix.settings.experimental-features = ["nix-command" "flakes" "repl-flake"];
  nixpkgs.config.allowUnfree = true;
#   nixpkgs.overlays = [inputs.hyprland.overlays.default];

  programs.nix-ld.enable = true;

  programs.dconf.enable = true;

  services.flatpak.enable = true;
  services.gvfs.enable = true;
  boot.supportedFilesystems = ["ntfs"];

  security.pam.services.swaylock = {};

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.NetworkManager.wantedBy = ["multi-user.target"];
  users.extraGroups.networkmanager.members = [vars.USER];
  networking.nameservers = ["1.1.1.1"];
  services.resolved.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_default_ttl" = 65;
}

