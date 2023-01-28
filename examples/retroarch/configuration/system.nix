{ lib, ... }:

{
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    password = "1234";
  };

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
      id    = lib.mkForce "12345678-1324-1234-0000-D00D00000420";
    };
  };

  fileSystems =
    let
      tmpfsConf = {
        device = "tmpfs";
        fsType = "tmpfs";
        neededForBoot = true;
      };
    in
    {
      "/" = lib.mkDefault {
        #autoResize = lib.mkForce false;
      };
      # Nothing is saved, except for the nix store being rehydrated.
      # XXX target more useful endpoints?
      # XXX see if we can have squashfs + FAT32 instead with this stage-1
      "/tmp" = tmpfsConf;
      "/var/log" = tmpfsConf;
      "/home" = tmpfsConf;
    }
  ;

}
