{
  description = "Xiaoxi654's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    polymc.url = "github:PolyMC/PolyMC";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations."xiaoxi-nixos-desktop" = import ./desktop {
      system = "x86_64-linux";
      inherit nixpkgs inputs;
    };
  };
}
