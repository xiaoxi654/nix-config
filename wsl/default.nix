{ system, nixpkgs, inputs }:

nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ./configuration.nix
    inputs.vscode-server.nixosModule
  ];
}
