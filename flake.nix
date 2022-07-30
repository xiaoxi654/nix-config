{
  description = "Xiaoxi654's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations."xiaoxi-nixos-desktop" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./desktop/configuration.nix
      ];
    };
  };
}
