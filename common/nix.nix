{ self, pkgs, lib, config, ... }:
let
  inherit (lib)
    mkOption
    elem
    getName
    ;
  inherit (lib.types) listOf str;
in
{
  options.aquaris = {
    insecureNames = mkOption {
      type = listOf str;
      default = [ ];
    };

    unfreeNames = mkOption {
      type = listOf str;
      default = [ ];
    };
  };

  config = {
    nixpkgs.config = {
      allowInsecurePredicate =
        p: elem (getName p) config.aquaris.insecureNames;

      allowUnfreePredicate =
        p: elem (getName p) config.aquaris.unfreeNames;
    };

    nix = {
      package = pkgs.lixPackageSets.latest.lix;

      distributedBuilds = true;

      registry.obscura.to = {
        type = "github";
        owner = "42LoCo42";
        repo = "obscura";
        inherit (self.inputs.obscura) rev;
      };

      settings = {
        allowed-users = [ "@wheel" ];

        builders-use-substitutes = true;

        auto-allocate-uids = true;
        use-cgroups = true;
        experimental-features = [ "auto-allocate-uids" "cgroups" ];
      };

      buildMachines = [{
        hostName = "nixremote-bunny";
        protocol = "ssh-ng";

        maxJobs = 4;
        speedFactor = 4;

        system = "aarch64-linux";
        supportedFeatures = [
          "benchmark"
          "big-parallel"
          "gccarch-armv8-a"
          "kvm"
          "nixos-test"
        ];
      }];
    };

    programs.ssh = {
      extraConfig = ''
        Host nixremote-bunny
        HostName exit.bunny.vpn
        Port 18213
        User nixremote
        Compression yes
        IdentityFile ${config.aquaris.secret "svc/nixremote"}
        ConnectTimeout 1
      '';

      knownHosts = {
        "[exit.bunny.vpn]:18213".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBbsL7HyOCM56ejtlWqEBG1YzQwX2KmZ3S5KzoGnWh/j";
      };
    };
  };
}
