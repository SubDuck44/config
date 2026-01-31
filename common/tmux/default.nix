{ config, lib, pkgs, ... }:
let
  split = builtins.path { path = ./split.sh; };
in
{
  programs.tmux = {
    enable = true;

    clock24 = true;
    escapeTime = 300;
    historyLimit = 2147483647;
    keyMode = "vi";
    mouse = true;
    shortcut = "w";
    terminal = "tmux-256color";

    extraConfig = ''
      set-option -g renumber-windows on

      bind -n C-S-Up    next
      bind -n C-S-Down  prev
      bind -n C-S-Left  prev
      bind -n C-S-Right next
      bind -n C-Up      select-pane -U
      bind -n C-Down    select-pane -D
      bind -n C-Left    select-pane -L
      bind -n C-Right   select-pane -R

      bind -n C-Enter run "${split} here"
      bind -n M-Enter run "${split} home"
      bind -n C-M-Enter new-window
    '';
  };

  home.shellAliases."t" = "tmux new-session -A -E -s 0";
}
