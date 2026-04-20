{ lib, ... }: {
  security.rtkit = {
    enable = true;
    args = [ "--debug" "--stderr" ];
  };

  nixpkgs.overlays = lib.singleton (_: prev: {
    rtkit = prev.rtkit.overrideAttrs (old: {
      prePatch = (old.prePatch or "") + ''
        sed -i '${builtins.concatStringsSep "|" [
          "s"
          "setgroups(0, NULL)"
          "setgroups(1, (gid_t[]) { 1 })"
          ""
        ]}' rtkit-daemon.c
      '';
    });
  });
}
