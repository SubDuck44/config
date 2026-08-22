{ self, lib, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      # TODO https://github.com/openzfs/zfs/issues/18760
      linuxPackages_zen.__extend.zfs_2_4.__output = {
        configureFlags.__append = [ "--enable-linux-experimental" ];
        meta.broken.__assign = false;
      };

      prettypst.__assign = obscura.my-prettypst;

      # https://github.com/3timeslazy/nix-search-tv/pull/30
      nix-search-tv.__output.src.__assign = prev.fetchFromGitHub {
        owner = "42LoCo42";
        repo = "nix-search-tv";
        rev = "3d4e8d6d6a3b2a8a857690378bfd03ef2856f72e";
        hash = "sha256-FLiUAztKoFScjg4gfnPfo1jSfIn8xQuJNKrgYhUDo0k=";
      };

      factorio-space-age.__input.makeDesktopItem.__hijack.exec.__prepend = "gamemoderun ";

      syncplay.__output = {
        patches.__append = [
          ./syncplay.patch
        ];

        postFixup.__append = ''
          rm $out/share/applications/syncplay-server.desktop
          sed -Ei 's|(Exec=syncplay .*)|\1 --no-store|' \
            $out/share/applications/syncplay.desktop
        '';
      };
    } // builtins.mapAttrs (_: x: { __assign = x; }) {
      inherit (obscura)
        avahi-proxy
        keysmash
        yellowcake
        ;

      inherit (obscura.nvidia.entries) nvtop;
    }));
}
