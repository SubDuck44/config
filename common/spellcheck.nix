{ pkgs, lib, ...}:let
  inherit(lib)
  pipe
  ;
in {
  home-manager.sharedModules = [{
    systemd.user.tmpfiles.rules = pipe [
      "en_US-large"
      "de_DE"
    ] [
      (map (x: pkgs.hunspellDicts.${x}))
      (x: pkgs.symlinkJoin {
        name = "hunspell-dicts";
        paths = x;
      })
      (x: [ "L+ %h/.config/enchant/hunspell - - - - ${x}/share/hunspell" ])
    ];
  }];
}
