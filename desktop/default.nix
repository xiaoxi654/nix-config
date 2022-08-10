{ system, nixpkgs, inputs }:

nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./software
    inputs.home-manager.nixosModules.home-manager
    inputs.nur.nixosModules.nur
  ];
}
