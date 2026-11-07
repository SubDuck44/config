{ self, ... }: {
  imports = [ self.inputs.nix-index-database.nixosModules.nix-index ];

  programs.nix-index.enable = true;

  home-manager.sharedModules = [{
    home.shellAliases = {
      nl = "nix-locate";
      nlr = "nl --regex";
      nlt = "nl --at-root"; # "top"
    };

    programs.zsh.initContent = ''
      nlb() {
        x="$1"; shift
        nix-locate --at-root --whole-name "$@" "/bin/$x"
      }

      nlp() {
        x="$1"; shift
        nix-locate --regex "$@" '/[^/]*'"$x"'[^/]*\.pc$'
      }
    '';
  }];
}
