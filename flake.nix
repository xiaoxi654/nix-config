{
  description = "Xiaoxi654's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    resign = {
      url = "github:NickCao/resign";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations."xiaoxi-nixos-desktop" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./desktop/configuration.nix
        inputs.home-manager.nixosModules.home-manager
      ];
    };
  };
}
