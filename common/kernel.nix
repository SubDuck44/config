{ pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
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
