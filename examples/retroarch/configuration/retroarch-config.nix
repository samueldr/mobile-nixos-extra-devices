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
    };
  };
  config = {
  };
}
