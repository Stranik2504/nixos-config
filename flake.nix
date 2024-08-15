{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hyprland = {
    #  url = "git+https://github.com/hyprwm/Hyprland.git?ref=refs/tags/v0.42.0&submodules=1";
    #  inputs.nixpkgs.follows = "nixpkgs";
    # };
    # split-monitor-workspaces = {
    #   url = "github:Duckonaut/split-monitor-workspaces/625f3f730cb392a5005144051bd9dcb25525fea0";
    #   inputs.hyprland.follows = "hyprland";
    # };
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable, ... }@inputs:
  let
    vars = import ./vars.nix;
    pkgs-unstable = import nixpkgs-unstable { system = "x86_64-linux"; };
  in {

    nixosConfigurations.${vars.HOSTNAME} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./system
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${vars.USER} = import ./home;

            extraSpecialArgs = {
              inherit inputs vars pkgs-unstable;
            };
          };
        }
      ];
      specialArgs = {
        inherit inputs vars pkgs-unstable;
      };
    };

  };
}
