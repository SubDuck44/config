{
  home-manager.sharedModules = [{
    programs.eza.theme = {
      filenames = {
        # dot stuff in home
        ".android".icon.glyph = "";
        ".factorio".icon.glyph = "󰈏";
        ".icons".icon.glyph = "";

        # main dirs in home
        "cfg".icon.glyph = "";
        "cod".icon.glyph = "";
        "doc".icon.glyph = "󰈙";
        "gay".icon.glyph = "󰺵";
        "gps".icon.glyph = "";
        "mem".icon.glyph = "";
        "org".icon.glyph = "";
        "rnd".icon.glyph = "󱗾";
        "sfx".icon.glyph = "";
      };
    };
  }];
}
