{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.mobile.hardware.socs;
in
{
  options.mobile = {
    hardware.socs.rockchip-rk3326.enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable when SOC is RK3326";
    };
    hardware.socs.rockchip-rk3399.enable = mkOption {
      type = types.bool;
      default = false;
      description = "enable when SOC is RK3399";
    };
  };

  config = mkMerge [
    {
      mobile = mkIf cfg.rockchip-rk3326.enable {
        system.system = "aarch64-linux";
      };
    }
    {
      mobile = mkIf cfg.rockchip-rk3399.enable {
        system.system = "aarch64-linux";
      };
    }
  ];
}
