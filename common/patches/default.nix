{ config, self, lib, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let
      inherit (prev.stdenv) system;
      obscura = self.inputs.obscura.packages.${system};
      blender-cuda = self.inputs.blender-cuda.packages.${system};
    in
    self.inputs.obscura.lib.infuse prev ({
      lixPackageSets.latest.__assign = prev.lixPackageSets.lix_2_96;
      lix.__assign = prev.lixPackageSets.lix_2_96.lix;

      hyprland.__assign = obscura.my-hypr-plugins.hyprland;
      hyprlandPlugins.__assign = obscura.my-hypr-plugins.entries;

      # TODO https://github.com/NixOS/nixpkgs/issues/576406
      linuxPackages_zen.__extend.v4l2loopback.__assign =
        prev.runCommand "v4l2loopback-fix" { } ''
          subdir=lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}
          mkdir -p $out/$subdir
          cd ${prev.linuxPackages_zen.v4l2loopback}/$subdir
          for f in *; do
            if [[ $f =~ ^modules ]]; then continue; fi
            cp -r $f $out/$subdir/$f
          done
        '';

      #################### PERMANENT ####################

      blender.__assign = blender-cuda.blender-with-cuda-unstable;

      gomuks-web .__assign = obscura.my-gomuks-web;
      prettypst  .__assign = obscura.my-prettypst;
      tuigreet   .__assign = obscura.my-tuigreet;

      factorio-space-age.__input.makeDesktopItem.__hijack.exec.__prepend = "gamemoderun ";

      syncplay.__output = {
        patches.__append = [
          ./syncplay.patch
        ];

        postFixup.__append = ''
          rm $out/share/applications/syncplay-server.desktop
          sed -Ei 's|(Exec=syncplay.*)|\1 --no-store|' \
          $out/share/applications/syncplay.desktop
        '';
      };
    } // builtins.mapAttrs (_: x: { __assign = x; }) {
      inherit (obscura)
        bun2nix
        keysmash
        molecule
        nomm
        ;

      inherit (obscura.nvidia.entries) nvtop;
    }));
}
