{
  description = "Xiaoxi654's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations = {
      "xiaoxi-nixos-desktop" = import ./desktop {
        system = "x86_64-linux";
        inherit nixpkgs inputs;
      };
      wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./wsl/configuration.nix
          inputs.vscode-server.nixosModule
        ];
      };
    };
  };
}
