{ config, lib, pkgs, ... }:
{
  imports = [
    ./system-type.nix
    ../../modules/modules-list.nix
  ];

  mobile.device.name = "anbernic-rg351p";
  mobile.device.identity = {
    name = "RG351P";
    manufacturer = "Anbernic";
  };

  boot.kernelParams = [
    #"quiet"
    #"vt.global_cursor_default=0"
    "console=tty0"
  ];

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { };
  };

  mobile.hardware = {
    soc = "rockchip-rk3326";
    ram = 1024 * 1;
    screen = {
      width = 240; height = 320; # installed 90°CW
    };
  };

  mobile.system.type = "odroid-style";

  # It seems Pine64 does not have an idVendor...
  mobile.usb.idVendor = "1209";  # http://pid.codes/1209/
  mobile.usb.idProduct = "0069"; # "common tasks, such as testing, generic USB-CDC devices, etc."

  # ff300000.usb

  # Mainline gadgetfs functions
  mobile.usb.gadgetfs.functions = {
    rndis = "rndis.usb0";
    mass_storage = "mass_storage.0";
    adb = "ffs.adb";
  };

  mobile.boot.stage-1.bootConfig = {
    # Used by target-disk-mode to share the internal drive
    storage.internal = "/dev/disk/by-path/platform-ff370000.dwmmc";
  };

  # XXX might not be needed
  # mobile.boot.stage-1.tasks = [ ./usb_role_switch_task.rb ];

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
