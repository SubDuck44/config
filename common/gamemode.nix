{ config, ... }: {
  programs.gamemode.enable = true;

  users.users = (builtins.mapAttrs (_: _: {
    extraGroups = [ "gamemode" ];
  })) config.aquaris.users;
}
