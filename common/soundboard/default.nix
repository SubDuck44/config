{ pkgs, ... }: {
  home-manager.sharedModules = [{
    wayland.windowManager.hyprland.extraConfig =
      let
        order = pkgs.writeShellScript "order" ''
          if pgrep -f 'mpv.*ORDER'; then
            pkill -f 'mpv.*ORDER'
          else
            mpv ${./ORDER.opus}
          fi
        '';

        godswill = pkgs.writeShellScript "godswill" ''
          if pgrep -f 'mpv.*deathofgodswill'; then
            pkill -f 'mpv.*deathofgodswill'
          else
            mpv ${./deathofgodswill.opus}
          fi
        '';
      in
      ''
        hl.bind(mainMod .. " + KP_Divide",   hl.dsp.exec_cmd("${order}"))
        hl.bind(mainMod .. " + KP_Multiply", hl.dsp.exec_cmd("${godswill}"))
      '';
  }];
}
