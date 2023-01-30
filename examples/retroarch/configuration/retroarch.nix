# Configuration to pick the ambiant retroarch into the local system
{ config, lib, pkgs, ... }:

let
  inherit (lib)
    optionalString
  ;
in
{
  environment.systemPackages = with pkgs; [
    cage
    config.wip.retroarch.wrapped
  ];

  hardware.opengl.enable = true;

  # Let userspace use the power key as a "menu" key.
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  # Signal VT1 ownership
  systemd.services."getty@tty1" = {
    enable = false;
  };

  systemd.services.games-session = {
    enable = true;
    after = [
      "systemd-user-sessions.service"
      "plymouth-start.service"
      "plymouth-quit.service"
      "systemd-logind.service"
      "getty@tty1.service"
    ];
    before = [ "graphical.target" ];
    wants = [ "dbus.socket" "systemd-logind.service" "plymouth-quit.service"];
    wantedBy = [ "graphical.target" ];
    partOf = [ "graphical.target" ];
    conflicts = [
      # Ensure there's no login prompt on the screen used for steam.
      "getty@tty1.service"
      # Ensures we don't run at the same time as display manager
      "display-manager.service"
    ];
    restartIfChanged = false;
    unitConfig.ConditionPathExists = "/dev/tty1";
    serviceConfig = {
      User = 1000;
      PAMName = "login";
      WorkingDirectory = "~";
      TTYPath = "/dev/tty1";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";
      StandardInput = "tty-fail";
      StandardOutput = "journal";
      StandardError = "journal";
      UtmpIdentifier = "tty1";
      UtmpMode = "user";
      Restart = "always";
    };
    script = ''
      ${pkgs.cage}/bin/cage \
        -s \
        ${optionalString (config.mobile.device.name == "anbernic-rg351p") "-r"} \
        ${config.wip.retroarch.wrapped}/bin/retroarch
    '';
  };

  # Ensures graphical target is ran.
  systemd.defaultUnit = "graphical.target";

  nixpkgs.overlays = [(
    final: super: {
      retroarch = final.callPackage ./retroarch { };
      retroarch-assets = super.retroarch-assets.overrideAttrs({ postInstall ? "", ... }: {
        postInstall = ''
          (
          cd $out/share/retroarch/assets
          PS4=" $ "
          set -x
          rm sounds/BGM.wav
          rm -r wallpapers
          rm -r Systematic FlatUX Automatic
          rm -r branding pkg switch
          rm -r devtools
          rm -r ctr
          rm -r scripts
          rm -r cfg
          cd xmb
          rm -r systematic neoactive retroactive automatic retrosystem dot-art daite pixel
          )
        '';
      });
    }
  )];
}
