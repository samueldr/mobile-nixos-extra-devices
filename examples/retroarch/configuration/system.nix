{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import ../pkgs)
  ];

  users.mutableUsers = false;
  users.users.games = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [
      "audio"
      "input"
      "networkmanager"
      "systemd-journal"
      "tty"
      "video"
      "wheel"
    ];
    password = "";
    home = "/userdata/Data/home";
  };

  mobile.beautification.silentBoot = true;
  mobile.beautification.splash = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = lib.mkForce false;
  };

  #services.getty.autologinUser = "nixos";

  boot.postBootCommands = lib.mkOrder (-1) ''
    brightness=10
    echo "Setting brightness to $brightness"
    if [ -e /sys/class/backlight/backlight/brightness ]; then
      echo $(($(cat /sys/class/backlight/backlight/max_brightness) * brightness / 100)) > /sys/class/backlight/backlight/brightness
    elif [ -e /sys/class/leds/lcd-backlight/max_brightness ]; then
      echo $(($(cat /sys/class/leds/lcd-backlight/max_brightness)  * brightness / 100)) > /sys/class/leds/lcd-backlight/brightness
    elif [ -e /sys/class/leds/lcd-backlight/brightness ]; then
      # Assumes max brightness is 100... probably wrong, but good enough, eh.
      echo $brightness > /sys/class/leds/lcd-backlight/brightness
    fi
  '';

  # Make the system rootfs different enough that mixing stage-1 and stage-2
  # will fail and not have weird unexpected behaviours.
  mobile.generatedFilesystems = {
    rootfs = lib.mkDefault {
      label = lib.mkForce "RETROARCH";
      ext4.partitionID = lib.mkForce "12345678-1324-1234-0000-D00D00000420";
    };
  };

  # This is always true, whether userdata is on FAT32 or ext4.
  systemd.tmpfiles.rules = [
    "d /userdata 0770 games users"
    "d /userdata/Data 0770 games users"
    "d /userdata/Data/home 0770 games users"
  ];

  # Ensures wlroots seats shenanigans can get a seat
  security.polkit.enable = true;

  # Keep only ~256MiB of logs
  # This is a lot of logs, but this is kept in the stateful directory of the userdata partition.
  # This may help with figuring out problems down the line.
  # NOTE: 4GiB is the upstream default for SystemMaxUse.
  services.journald.extraConfig = ''
    SystemMaxUse=256M
  '';
}
