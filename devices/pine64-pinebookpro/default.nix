{ config, lib, pkgs, ... }:
{
  # Import experimental modules
  imports = [ ../../modules/modules-list.nix ];

  mobile.device.name = "pine64-pinebookpro";
  mobile.device.identity = {
    name = "PINEBOOK Pro";
    manufacturer = "Pine64";
  };

  boot.kernelParams = [
    # Serial console on ttyS2, using the dedicated cable.
    "cma=32M"
    "console=ttyS2,1500000n8"
    "earlycon=uart8250,mmio32,0xff1a0000"
    "earlyprintk"

    "quiet"
    "vt.global_cursor_default=0"
  ];

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { kernelPatches = pkgs.defaultKernelPatches; };
  };

  mobile.hardware = {
    soc = "rockchip-rk3399";
    ram = 1024 * 4;
    screen = {
      width = 1920; height = 1080;
    };
  };

  mobile.system.type = "u-boot";
  mobile.quirks.u-boot.package = pkgs.callPackage ./u-boot {};
}
