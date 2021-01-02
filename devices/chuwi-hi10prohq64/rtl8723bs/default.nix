#
# rtl8723bs
# =========
#
# Wifi is supported, I believe, starting with 4.11 or 4.12.
# Use a patched kernel or another package while waiting.
#
# This is for the bluetooth userspace tools, and to fix some quirks.
#
{ pkgs, ... }:

let
  overlay = (self: super: {
    rtl8723bs-bluetooth = self.callPackage ./rtl8723bs-bluetooth.nix { };
  });
in
{
  #
  # Bluetooth
  # ---------
  #

  ## environment.systemPackages = with pkgs; [
  ##   #rtl8723bs-bluetooth
  ## ];

  hardware.bluetooth.enable = true;

  nixpkgs.overlays = [
    overlay
  ];

  # FIXME : export systemd service in package.
  systemd.services.rtl8723bs-bluetooth = {
    description = "Bluetooth userspace";
    #requires = "network.target";
    wantedBy = [ "bluetooth.service" ];
    serviceConfig.ExecStart = "${pkgs.rtl8723bs-bluetooth}/lib/start_bt.sh";
    enable = true;
  };

  #
  # Quirks
  # ------
  #

  # Disables the mac address randomization
  # The common rtl8723bs wifi module does not play well at boot with it.
  environment.etc."NetworkManager/conf.d/30-mac-randomization.conf" = {
    source = pkgs.writeText "30-mac-randomization.conf" ''
        [device-mac-randomization]
        wifi.scan-rand-mac-address=no

        [connection-mac-randomization]
        ethernet.cloned-mac-address=preserve
        wifi.cloned-mac-address=preserve
    '';
  };
}
