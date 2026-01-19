{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    obscura.url = "github:42loco42/obscura";
    keysmash.url = "github:42loco42/keysmash";
    aquaris = {
      url = "github:42loco42/aquaris";
      flake = false;
    };
  };
  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations = {
      # laptop
      boobsos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [ ./boobsos ./common ];
      };

      # desktop
      tittyos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [ ./tittyos ./common ];
      };
    };
  };
}

