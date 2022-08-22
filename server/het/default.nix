{ system, nixpkgs }:

nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ./configuration.nix
  ];
}
