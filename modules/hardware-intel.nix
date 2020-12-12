{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.mobile.hardware.socs;
in
{
  options.mobile = {
    hardware.socs.intel-atom-x5-z8350.enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable when CPU is Intel Atom x5-Z8350";
    };
  };

  config = mkMerge [
    {
      mobile = mkIf cfg.intel-atom-x5-z8350.enable {
        system.system = "x86_64-linux";
      };
    }
  ];
}
