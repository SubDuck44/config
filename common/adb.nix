{ pkgs, config, ... }: {
  home-manager.sharedModules = [{
    home.packages = with pkgs; [
      android-tools
    ];

    aquaris.persist = {
      ".android" = { };
    };
  }];

  users.users = (builtins.mapAttrs (_: _: {
    extraGroups = [ "adbusers" ];
  })) config.aquaris.users;
}
