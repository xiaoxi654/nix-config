{ system, nixpkgs, inputs }:

nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit self; };
  modules = [
    ./configuration.nix
    inputs.sops-nix.nixosModules.sops
  ];
}
