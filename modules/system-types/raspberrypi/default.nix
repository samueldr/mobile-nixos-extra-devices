{ config, pkgs, lib, modules, baseModules, ... }:

let
  inherit (pkgs) hostPlatform buildPackages imageBuilder runCommandNoCC;
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.mobile.quirks.u-boot;
  inherit (cfg) soc;
  inherit (config) system;
  deviceName = config.mobile.device.name;
  device_info = config.mobile.device.info;
  kernel = config.mobile.boot.stage-1.kernel.package;
  kernel_file = "${kernel}/${kernel.file}";

  enabled = config.mobile.system.type == "raspberrypi";

  configTxt = pkgs.writeText "${deviceName}-config.txt" ''
    # ****************
    # * Mobile NixOS *
    # ****************
    #
    # Built for ${deviceName}
    #

    enable_uart=1

    # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
    # when attempting to show low-voltage or overtemperature warnings.
    avoid_warnings=1

    ${lib.optionalString (pkgs.targetPlatform.system == "aarch64-linux") ''
    arm_64bit=1
    ''}

    kernel=mobile-nixos/boot/kernel
    initramfs mobile-nixos/boot/stage-1 followkernel
  '';

  cmdlineTxt = pkgs.writeText "${deviceName}-cmdline.txt" ''
    ${lib.concatStringsSep " " config.boot.kernelParams}
  '';

  rpiFirmware = "${pkgs.raspberrypifw}";

  boot-partition =
    imageBuilder.fileSystem.makeFAT32 {
      name = "MONIXOSBOOT";
      partitionID = "5edb6590";
      # Let's give us a *bunch* of space to play around.
      # And let's not forget we want to fit the kernel and stage-1 twice for upgrades.
      size = imageBuilder.size.MiB 256;
      bootable = true;
      populateCommands = ''
        mkdir -vp mobile-nixos/boot
        (
        cd mobile-nixos/boot
        cp -v ${config.system.build.initrd} stage-1
        cp -v ${kernel_file} kernel
        )
        cp -v ${configTxt} ./config.txt
        cp -v ${cmdlineTxt} ./cmdline.txt

        for f in ${pkgs.raspberrypifw}/share/raspberrypi/boot/*.{dat,bin,elf}; do
          cp -vf "$f" ./
        done

        cp -vf "${config.mobile.boot.stage-1.kernel.package}"/dtbs/broadcom/*.dtb ./
      '';
    }
  ;

  disk-image = imageBuilder.diskImage.makeMBR {
    name = "mobile-nixos";
    diskID = "01234567";

    partitions = [
      (imageBuilder.gap (imageBuilder.size.MiB 4))
      config.system.build.boot-partition
      config.system.build.rootfs
    ];
  };

in
{
  options.mobile = {
    quirks.raspberrypi = {
      #soc.family = mkOption {
      #  type = types.enum [ "allwinner" "rockchip" ];
      #  internal = true;
      #  description = ''
      #    The (internal to this project) family name for the bootloader.
      #    This is used to build upon assumptions like the location on the
      #    backing storage that u-boot will be "burned" at.
      #  '';
      #};
      #package = mkOption {
      #  type = types.package;
      #  description = ''
      #    Which package handles u-boot for this system.
      #  '';
      #};
      #initialGapSize = mkOption {
      #  type = types.int;
      #  description = ''
      #    Size (in bytes) to keep reserved in front of the first partition.
      #  '';
      #};
      #additionalCommands = mkOption {
      #  type = types.str;
      #  default = "";
      #  description = ''
      #    Additional U-Boot commands to run.
      #  '';
      #};
    };
  };

  config = lib.mkMerge [
    { mobile.system.types = [ "raspberrypi" ]; }
    (mkIf enabled {
      system.build = {
        inherit boot-partition disk-image;
        default = system.build.disk-image;
      };
    })
  ];
}
