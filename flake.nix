{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    obscura.url = "github:42loco42/obscura";
  };
  outputs = inputs@{ self, nixpkgs, home-manager, obscura, ... }: {
    nixosConfigurations.tittyos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit self; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.melinda = ./home.nix;
        }
      ];
    };
  };
}

