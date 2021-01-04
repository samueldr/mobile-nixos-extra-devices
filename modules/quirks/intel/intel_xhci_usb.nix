{ config, lib, pkgs, ... }:

let
  cfg = config.mobile.quirks.intel;
  inherit (lib) mkIf mkOption types;
in
{
  options.mobile = {
  quirks.intel.intel_xhci_usb_sw-role-switch.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable this on a device which requires usb role-switch to be
        configured for OTG to work.
      '';
    };
  };

  config = mkIf (cfg.intel_xhci_usb_sw-role-switch.enable) {
    mobile.boot.stage-1.tasks = [ ./intel_xhci_usb_switch-task.rb ];
    systemd.services.dwc3-otg_switch = {
      description = "Setup the Intel XHCI controller in OTG mode";
      wantedBy = [ "multi-user.target" ];
      script = ''
        echo device > /sys/class/usb_role/intel_xhci_usb_sw-role-switch/role
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}
