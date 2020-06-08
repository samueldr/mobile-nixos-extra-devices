{ config, lib, pkgs, ... }:
{
  # Import experimental modules
  imports = [ ../../modules/modules-list.nix ];

  mobile.device.name = "raspberrypi-raspberrypi4";
  mobile.device.identity = {
    name = "Raspberry Pi 4 Model B";
    manufacturer = "Raspberry Pi Foundation";
  };

  boot.kernelParams = [
    "cma=32M"

    "earlyprintk"
    "earlycon=uart8250,mmio32,0x3f215040 "
    "console=tty1"
    "console=serial0,115200"

    "quiet"
    "vt.global_cursor_default=0"
  ];

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { kernelPatches = pkgs.defaultKernelPatches; };
  };

  mobile.hardware = {
    soc = "broadcom-bcm2711";
    # Smallest amount of RAM available
    # Up to 8GiB
    ram = 1024 * 1;
  };

  mobile.system.type = "raspberrypi";

  #mobile.device.firmware = pkgs.callPackage ./firmware {};
  #mobile.boot.stage-1.firmware = [
  #  config.mobile.device.firmware
  #];
}
