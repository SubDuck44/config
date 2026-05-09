{ pkgs, ... }: {
  home-manager.sharedModules = [{
    wayland.windowManager.hyprland.extraConfig = ''
      bind = $mainMod, KP_Divide, exec, ${pkgs.writeShellScript "order" ''
        if pgrep -f 'mpv.*ORDER'; then
          pkill -f 'mpv.*ORDER'
        else
          mpv ${./ORDER.opus}
        fi
      ''}
      bind = $mainMod, KP_Multiply, exec, ${pkgs.writeShellScript "godswill" ''
        if pgrep -f 'mpv.*deathofgodswill'; then
          pkill -f 'mpv.*deathofgodswill'
        else
          mpv ${./deathofgodswill.opus}
        fi
      ''}
    '';
  }];
}
