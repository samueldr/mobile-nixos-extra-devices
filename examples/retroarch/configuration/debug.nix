{ config, lib, pkgs, ... }:

let
  # Only enable `adb` if we know how to.
  # FIXME: relies on implementation details. Poor separation of concerns.
  enableADB = 
  let
    value =
      config.mobile.usb.mode == "android_usb" ||
      (config.mobile.usb.mode == "gadgetfs" && config.mobile.usb.gadgetfs.functions ? adb)
    ;
  in
    if value then value else
    builtins.trace "warning: unable to enable ADB for this device." value
  ;
in
{
  environment.systemPackages = with pkgs; [
    input-utils
  ];

  # If possible, enable ADB!
  mobile.adbd.enable = lib.mkDefault enableADB;

  # Makes it so nix path registration happens, which in turn makes the store proper.
  # Making the store proper means that `nix-copy-closure` and such works as expected.
  nix.enable = lib.mkForce true;

  # Silent boot is problematic when debugging
  mobile.beautification.silentBoot = lib.mkForce false;
  mobile.beautification.splash = lib.mkForce false;

  # Re-enable console things
  console.enable = lib.mkForce true;

  systemd.services.games-session = {
    serviceConfig = {
      # We want "quit retroarch" to drop to a console when debugging issues.
      Restart = lib.mkForce "on-failure";
    };
  };
}
