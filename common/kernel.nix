{ pkgs, ... }:
let
  pkgs' = pkgs;

  # pkgs' = (import (builtins.fetchTarball {
  #   url = "https://github.com/nixos/nixpkgs/tarball/";
  #   sha256 = "sha256-3av0pIjlOWQ6rDbNOmpUSvbNnJkGORQKKjb4LtCZsIY=";
  # })) {
  #   config.allowUnfree = true; # ugly >_<
  #   inherit (pkgs.stdenv) system;
  # };
in
{
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
