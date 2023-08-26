{ config, lib, pkgs, ... }:
{
  imports = [
    ./system-type.nix
    ../../modules/modules-list.nix
  ];

  mobile.device.name = "odroid-go-ultra";
  mobile.device.identity = {
    name = "Go Ultra";
    manufacturer = "ODROID";
  };

  boot.kernelParams = [
    "no_console_suspend"
    "consoleblank=0"
    "fbcon=rotate:3"
  ];

  mobile.boot.serialConsole = "ttyAML0,115200n8";

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { };
  };

  mobile.hardware = {
    soc = "amlogic-g12b";
    ram = 1024 * 2; # ?
    screen = {
      width = 854; height = 480; # installed 90°CW
    };
  };

  mobile.system.type = "odroid-go-ultra-style";

  mobile.usb.idVendor = "1209";
  mobile.usb.idProduct = "0069";

###  # Mainline gadgetfs functions
###  mobile.usb.gadgetfs.functions = {
###    rndis = "rndis.usb0";
###    mass_storage = "mass_storage.0";
###    adb = "ffs.adb";
###  };
###
###  mobile.boot.stage-1.bootConfig = {
###    # Used by target-disk-mode to share the internal drive
###    storage.internal = "/dev/disk/by-path/platform-ff370000.dwmmc";
###  };

  # Minimum driver hardware requirements
  mobile.kernel.structuredConfig = [
    (helpers: with helpers; {
      # TODO
    })
  ];

  # Serial access is a bit out of reach.
  # mobile.boot.stage-1.shell.console = "ttyFIQ0";
  # mobile.boot.stage-1.shell.shellOnFail = true;
}
