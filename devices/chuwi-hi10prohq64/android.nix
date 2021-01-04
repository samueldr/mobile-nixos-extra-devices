# What?
# =====
#
# Allows producing android boot.img for this tablet.
# Using kernelflinger from the vendor, this allows booting using
# the android boot flow, but more importantly, using `fastboot boot`.

{ lib, baseModules, modules, ... }:

let
  # FIXME: Do not rely on NIX_PATH here
  android = (import <mobile-nixos/lib/eval-config.nix> {
    inherit baseModules;
    modules = modules ++ [{
      mobile.system.android = {
        boot_as_recovery = false;
        has_recovery_partition = true;
        bootimg.flash = {
          offset_base = "0x10000000";
          offset_kernel = "0x00008000";
          offset_ramdisk = "0x01000000";
          offset_second = "0x00f00000";
          offset_tags = "0x00000100";
          pagesize = "2048";
        };
      };
      mobile.system.type = lib.mkForce "android";
    }];
  });
in
{
  system.build.android-bootimg = android.config.system.build.android-bootimg;
  system.build.android-recovery = android.config.system.build.android-recovery;
}
