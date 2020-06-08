{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.mobile.hardware.socs;
in
{
  options.mobile = {
    hardware.socs.broadcom-bcm2711.enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable when SOC is BCM2711";
    };
  };

  config = mkMerge [
    {
      mobile = mkIf cfg.broadcom-bcm2711.enable {
        system.system = "aarch64-linux";
      };
    }
  ];
}
