{ pkgs, config, ... }: {
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };

    spiceUSBRedirection.enable = true;
  };

  home-manager.sharedModules = [{
    home.packages = with pkgs; [
      virt-manager
    ];
  }];

  users.users = (builtins.mapAttrs (_: _: {
    extraGroups = [ "libvirtd" ];
  })) config.aquaris.users;
}
