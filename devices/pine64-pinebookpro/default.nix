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
    "console=ttyS2,1500000n8"
    "earlycon=uart8250,mmio32,0xff1a0000"
    "earlyprintk"

    "quiet"
    "vt.global_cursor_default=0"
  ];

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { };
  };

  mobile.hardware = {
    soc = "rockchip-rk3399";
    ram = 1024 * 4;
    screen = {
      width = 1920; height = 1080;
    };
  };

  mobile.system.type = "u-boot";

  mobile.device.firmware = pkgs.callPackage ./firmware {};
  mobile.boot.stage-1.firmware = [
    config.mobile.device.firmware
  ];

  # The controller is hidden from the OS unless started using the "android"
  # launch option in the weird UEFI GUI chooser.
  mobile.usb.mode = "gadgetfs";

  # It seems Pine64 does not have an idVendor...
  mobile.usb.idVendor = "1209";  # http://pid.codes/1209/
  mobile.usb.idProduct = "0069"; # "common tasks, such as testing, generic USB-CDC devices, etc."

  # Mainline gadgetfs functions
  mobile.usb.gadgetfs.functions = {
    rndis = "rndis.usb0";
    mass_storage = "mass_storage.0";
    adb = "ffs.adb";
  };

  mobile.boot.stage-1.bootConfig = {
    # Used by target-disk-mode to share the internal drive
    storage.internal = "/dev/disk/by-path/platform-fe330000.sdhci";
  };

  #mobile.boot.stage-1.tasks = [ ./usb_role_switch_task.rb ];
}
