{ pkgs, ... }:
let
  # TODO unpin on next zfs release
  pkgs' = (import (builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/tarball/a799d3e3886da994fa307f817a6bc705ae538eeb";
    sha256 = "sha256-3av0pIjlOWQ6rDbNOmpUSvbNnJkGORQKKjb4LtCZsIY=";
  })) {
    config.allowUnfree = true; # ugly >_<
    inherit (pkgs.stdenv) system;
  };
in
{
  # HACK THIS SHOULD NOT BE REQUIRED
  # SOMETHING IS INCOMPATIBLE BETWEEN MAIN & PIN
  hardware.deviceTree.enable = false;
  system.boot.loader.kernelFile = "bzImage";

  boot = {
    kernelPackages = pkgs'.linuxPackages_zen;
    zfs.package = pkgs'.zfs;
  };

  aquaris.persist.dirs = {
    "/root/.cache/pandemonium" = { };
  };

  services = {
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    scx = {
      enable = true;
      package = pkgs.scx.rustscheds;
      scheduler = "scx_pandemonium";
    };
  };
}
