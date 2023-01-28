{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    retroarch
  ];

  hardware.opengl.enable = true;

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  # Ensure retroarch owns VT1 entirely
  systemd.services."getty@tty1" = {
    enable = false;
  };

  systemd.services.retroarch = {
    description = "Retroarch";
    enable = true;
    after = [
      "systemd-user-sessions.service"
      "plymouth-start.service"
      "plymouth-quit.service"
      "systemd-logind.service"
      "getty@tty1.service"
    ];
    wants = [ "dbus.socket" "systemd-logind.service" "plymouth-quit.service"];
    #before = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    partOf = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "/dev/tty1";
    serviceConfig = {
      SyslogIdentifier = "retroarch";
      ExecStart = ''
        ${pkgs.retroarch}/bin/retroarch
      '';
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
    conflicts = [
      # Ensure there's no login prompt on the screen used for steam.
      "getty@tty1.service"
      # Ensures we don't run at the same time as a display manager
      "display-manager.service"
    ];
  };
}
