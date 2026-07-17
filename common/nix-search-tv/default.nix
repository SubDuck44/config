{ pkgs, ... }: {
  home-manager.sharedModules = [{
    aquaris.persist = {
      ".cache/nix-search-tv" = { };
    };

    home.packages = [
      (pkgs.writeShellApplication {
        name = "ntv";

        runtimeInputs = with pkgs; [
          fzf
          nix-search-tv
        ];

        text = builtins.readFile ./main.sh;
      })
    ];

    wayland.windowManager.hyprland.extraConfig = ''
      hl.bind("SUPER + CTRL + n", hl.dsp.exec_cmd("foot ntv", {
        fullscreen_state = "1 0",
      }))
    '';
  }];
}
