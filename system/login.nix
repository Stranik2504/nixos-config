{
  pkgs,
  pkgs-unstable,
  lib,
  ...
}: let
in {
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  environment.systemPackages = with pkgs; [libsecret];
  programs.seahorse.enable = true;

  services.displayManager.sessionPackages = [ pkgs-unstable.hyprland ];
  services.displayManager.sddm.enable = true;
}
