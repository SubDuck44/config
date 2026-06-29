{ pkgs, config, ... }: {
  virtualisation = {
    libvirtd = {
      enable = true;

      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [ virtiofsd ];
      };
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
