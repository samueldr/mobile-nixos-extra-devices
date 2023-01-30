{ lib, config, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.wip.retroarch;
in
{
  options = {
    wip.retroarch = {
      wrapped = mkOption {
        type = types.package;
        internal = true;
      };
      cores = mkOption {
        type = with types; listOf package;
      };
    };
  };
  config = {
    wip.retroarch.cores = with pkgs.libretro.override { inherit (pkgs) retroarch; }; [
      fceumm
      gambatte
      #gpsp
      pcsx-rearmed
      picodrive
      snes9x2005-plus

      # Standalone
      thepowdertoy
    ];
    wip.retroarch.wrapped = pkgs.callPackage (
      { symlinkJoin
      , writeText
      , retroarch
      , selectedRetroArchCores
      }:
      let
        forcedConfig = writeText "retroarch-forced-fragment.cfg" ''
          core_info_cache_enable = "false"

          # Restart is buggy on some platforms...
          # ... and undesirable UX-wise...
          menu_show_restart_retroarch = "false"
        '';
      in
      symlinkJoin {
        name = "retroarch-wrapped";
        paths = selectedRetroArchCores;
        postBuild = ''
          mkdir -p $out/bin
          cat <<EOF > $out/bin/retroarch
          #!/bin/sh
          exec -a retroarch \
            ${retroarch}/bin/retroarch \
            --libretro=${placeholder "out"}/lib/retroarch/cores \
            --appendconfig=${forcedConfig} \
            "\$@"
          EOF
          chmod +x $out/bin/retroarch
        '';
      }
    ) {
      selectedRetroArchCores = cfg.cores;
    };
  };
}
