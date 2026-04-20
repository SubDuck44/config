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

      registry.obscura.to = {
        type = "github";
        owner = "42LoCo42";
        repo = "obscura";
        inherit (self.inputs.obscura) rev;
      };

      settings = {
        allowed-users = [ "@wheel" ];

        auto-allocate-uids = true;
        use-cgroups = true;
        experimental-features = [ "auto-allocate-uids" "cgroups" ];
      };
    };
  };
}
