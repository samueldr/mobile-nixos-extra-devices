# Configuration to configure the ambiant retroarch for the current system.
{ lib, config, ... }:

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
      buildType = mkOption {
        default = "default";
        type = types.enum [ "default" "odroidgo2" ];
      };
    };
  };
  config = {
    wip.retroarch = mkMerge [
      (mkIf (config.mobile.device.name == "anbernic-rg351p") {
        buildType = "odroidgo2";
      })
    ];
    nixpkgs.overlays = [(
      final: super: {
        retroarch = final.callPackage ./retroarch {
          inherit (cfg) buildType;
        };
        retroarch-assets = super.retroarch-assets.overrideAttrs({ postInstall ? "", ... }: {
          postInstall = ''
            (
            cd $out/share/retroarch/assets
            PS4=" $ "
            set -x
            rm sounds/BGM.wav
            rm -r wallpapers
            rm -r Systematic FlatUX Automatic
            rm -r branding pkg switch
            rm -r devtools
            rm -r ctr
            rm -r scripts
            rm -r cfg
            cd xmb
            rm -r systematic neoactive retroactive automatic retrosystem dot-art daite pixel
            )
          '';
        });
      }
    )];
  };
}
