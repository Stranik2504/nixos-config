{pkgs, inputs, vars, ...}: {
  imports = [
    ./apps.nix
    ./dev.nix
    ./hyprland.nix
    ./lockscreen.nix
    ./packages.nix
    ./theme.nix
    ./unclutter.nix
    ./waybar.nix
    # ./libs.nix
    ./wezterm
    ./nix-ld.nix
  ];
  home.username = vars.USER;
  home.homeDirectory = "/home/" + vars.USER;
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  xdg.enable = true;
  home.stateVersion = "24.05";
}
