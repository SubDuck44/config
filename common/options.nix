{ config, lib, self, ... }:
let
  inherit (lib) mkOption elem getName;
  inherit (lib.types) listOf str;
in
{
  options.tits = {
    unfreeNames = mkOption {
      type = listOf str;
      default = [ ];
      description = "Names of unfree packages";
    };
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = p: elem (getName p) config.tits.unfreeNames;
  };
}
