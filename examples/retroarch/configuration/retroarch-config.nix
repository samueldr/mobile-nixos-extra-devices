{ lib, config, pkgs, ... }:

let
  inherit (lib)
    attrNames
    concatMapStringsSep
    filterAttrs
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.wip.retroarch;

  keptConfig = filterAttrs (k: v: v != null) cfg.config;
  forcedConfig = pkgs.writeText "retroarch-forced-fragment.cfg" (
    concatMapStringsSep "\n" (k:
      "${k} = ${builtins.toJSON keptConfig."${k}"}"
    ) (attrNames keptConfig)
  );
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
      config = mkOption {
        type = with types; nullOr (attrsOf str);
        default = {};
        description = ''
          RetroArch options that will be forced via --appendconfig.

          Use `null` to remove a previously defined value.

          All values are strings, that is true for the configuration format too.
        '';
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
    wip.retroarch.config = {
    };
    wip.retroarch.wrapped = pkgs.callPackage (
      { symlinkJoin
      , retroarch
      , selectedRetroArchCores
      , forcedConfig
      }:
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
      inherit forcedConfig;
    };
  };
}
