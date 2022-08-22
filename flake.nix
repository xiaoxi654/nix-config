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
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, deploy-rs, ... }: {
    nixosConfigurations = {
      desktop = import ./desktop { system = "x86_64-linux"; inherit nixpkgs inputs; };
      wsl = import ./wsl { system = "x86_64-linux"; inherit nixpkgs inputs; };
      het = import ./server/het { system = "x86_64-linux"; inherit nixpkgs; };
    };
    deploy = {
      nodes = {
        het = {
          sshUser = "xiaoxi";
          user = "root";
          hostname = "2a01:4f9:4a:286f:1:110::1";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.het;
          };
        };
      };
    };
  };
}
