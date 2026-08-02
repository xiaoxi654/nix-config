{
    description = "Nix Flake for Xiaoxi654's Servers";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        deploy-rs = {
            url = "github:serokell/deploy-rs";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, deploy-rs, sops-nix }@inputs: {
        nixosConfigurations."MatrixServer" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ./MatrixServer/configuration.nix
                sops-nix.nixosModules.sops
            ];
        };

        deploy = {
            sshUser = "xiaoxi";
            user = "root";
            fastConnection = true;
            nodes = {
                "MatrixServer" = {
                    hostname = "matrix.xiaoxi654.dn42";
                    profiles.system = {
                        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."MatrixServer";
                    };
                };
            };
        };
    };
}
