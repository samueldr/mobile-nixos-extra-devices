{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
  ;
in
{
  config = mkIf (config.mobile.device.name == "anbernic-rg351p") {
    systemd.services.rg351p-js2xbox = {
      wantedBy = [
        "games-session.service"
        "graphical.target"
      ];
      enable = true;
      script = ''
        exec ${pkgs.rg351p-js2xbox}/bin/rg351p-js2xbox --silent -t oga_joypad
      '';
    };
  };
}
