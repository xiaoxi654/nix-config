{
  description = "Xiaoxi654's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nur.url = "github:nix-community/NUR";
    xiaoxi-repo = {
      url = "github:xiaoxi654/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      desktop = import ./desktop { system = "x86_64-linux"; inherit nixpkgs inputs; };
      wsl = import ./wsl { system = "x86_64-linux"; inherit nixpkgs inputs; };
    };
  };
}
