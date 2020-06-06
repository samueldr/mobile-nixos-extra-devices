{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkMerge mkOption types;
  inherit (pkgs) imageBuilder;
  cfg = config.mobile.hardware.socs;
  initialGapSize = 
    # Start of the "magic" location bs=512 seek=16384
    (512 * 16384) +
    # Current u-boot size: 838K, so let's leave a *bunch* of room.
    (imageBuilder.size.MiB 2)
  ;
in
{
  options.mobile = {
    hardware.socs.rockchip-rk3399.enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable when SOC is RK3399";
    };
  };

  config = mkMerge [
    {
      mobile = mkIf cfg.rockchip-rk3399.enable {
        system.system = "aarch64-linux";
        quirks.u-boot = {
          soc.family = "rockchip";
          inherit initialGapSize;
        };
      };
    }
  ];
}
