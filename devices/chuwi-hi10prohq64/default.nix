{ config, lib, pkgs, ... }:

let
  # HACK: temporarily disabled for the kernel hack.
  # ATTRS{name}=="silead_ts", ENV{LIBINPUT_CALIBRATION_MATRIX}="0.012379 3.232383 -0.009482 2.197900 0.004014 -0.061551 0.000000 0.000000 1.000000"
  extraUdevRules = ''
  '';
in
{
  imports = [
    ./rtl8723bs
    # Import experimental modules
    ../../modules/modules-list.nix
  ];

  mobile.device.name = "chuwi-hi10prohq64";
  mobile.device.identity = {
    name = "Hi10 Pro (HQ64)";
    manufacturer = "CHUWI";
  };

  boot.kernelParams = [
    "quiet"
    "vt.global_cursor_default=0"
    "console=tty2"
  ];

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { };
  };

  mobile.hardware = {
    soc = "intel-atom-x5-z8350";
    ram = 1024 * 4;
    screen = {
      width = 1200; height = 1920;
    };
  };

  mobile.system.type = "uefi";

  mobile.device.firmware = pkgs.callPackage ./firmware {};
  mobile.boot.stage-1.firmware = [
    config.mobile.device.firmware
  ];

  # Supports rebooting into generation kernel through kexec.
  mobile.quirks.supportsStage-0 = true;

  # Hardware quirks
  # ---------------

  # Touchscreen calibration matrix
  # Possibly different per-device

  # For stage-1
  mobile.boot.stage-1.extraUdevRules = extraUdevRules;

  # For the booted system
  services.udev.extraRules = extraUdevRules;
}
