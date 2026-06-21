{
  inputs = {
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
    };

    aquaris = {
      url = "github:42loco42/aquaris";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        obscura.follows = "obscura";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    obscura.url = "github:42loco42/obscura";

    keysmash.url = "github:42loco42/keysmash";
  };

  outputs = { aquaris, self, ... }: aquaris self rec {
    ssh = {
      melinda = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxPD8M1DV0k5QY283lo0QIpmUYCjUlYvHwKYkk8j9Gn";
      nori = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBH2eZZkiQ53veJRiLi/JbVU/CD2oKC/TN7Ope3LiCChAAAABHNzaDo=";
    };

    users = {
      melinda = {
        description = "Melinda";

        sshKeys = with ssh; [ melinda nori ];

        git = {
          email = "melinda.stobbe@mail.de";
          key = ssh.melinda;
        };
      };
    };
  };
}
