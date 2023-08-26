{ config, pkgs, lib, ... }:

let
  enabled = config.mobile.system.type == "odroid-style";

  inherit (config.mobile.outputs) recovery stage-0;
  inherit (pkgs) imageBuilder;
  inherit (lib)
    mkBefore
    mkDefault
    mkIf
    mkOption
    types
  ;
  deviceName = config.mobile.device.name;
  kernel = stage-0.mobile.boot.stage-1.kernel.package;
  kernel_file = "${kernel}/${if kernel ? file then kernel.file else pkgs.stdenv.hostPlatform.linux-kernel.target}";
  boot-partition = config.mobile.generatedFilesystems.boot.output;

  # GPIO a15 is the vibrator motor.
  bootini = pkgs.writeText "${deviceName}-boot.ini" ''
    ODROIDGO2-UBOOT-CONFIG

    setenv dtb_name       "rk3326-rg351p-linux.dtb"
    setenv ramdisk_addr_r "0x01100000"
    setenv fdt_addr_r     "0x01f00000"
    setenv kernel_addr_r  "0x02008000"

    setenv bootargs ${lib.concatStringsSep " " config.boot.kernelParams}

    gpio toggle a15 # on
    sleep 0.15
    gpio toggle a15 # off
    sleep 0.1
    gpio toggle a15 # on
    sleep 0.3
    gpio toggle a15 # off

    load mmc 1:1 ''${kernel_addr_r}   /System/Boot/kernel
    load mmc 1:1 ''${fdt_addr_r}      /System/Boot/dtbs/rockchip/''${dtb_name}
    load mmc 1:1 ''${ramdisk_addr_r}  /System/Boot/stage-1
    setenv ramdisk_size ''${filesize}

    booti ''${kernel_addr_r} ''${ramdisk_addr_r}:''${ramdisk_size} ''${fdt_addr_r};

    sleep 0.9
    gpio toggle a15
    sleep 0.9
    gpio toggle a15
    sleep 0.9
    gpio toggle a15
    sleep 0.9
    gpio toggle a15
    sleep 0.9
  '';
in
{
  options.mobile = {
    outputs = {
      odroid-style = {
        bootini = mkOption {
          type = types.package;
          internal = true;
          visible = false;
        };
        boot-partition = mkOption {
          type = types.package;
          description = ''
            Boot partition for the system.
          '';
          visible = false;
        };
        disk-image = lib.mkOption {
          type = types.package;
          description = ''
            Full Mobile NixOS disk image for a u-boot-based system.
          '';
          visible = false;
        };
      };
    };
  };

  config = lib.mkMerge [
    { mobile.system.types = [ "odroid-style" ]; }
    (mkIf enabled {
      mobile.generatedDiskImages.disk-image = {
        partitioningScheme = "mbr"; # [sic]
        partitions = mkBefore [
          {
            name = "u-boot";
            # XXX use the prebuilt U-Boot
            bootable = true;
            raw = ./u-boot.bin;
            offset = 512;
            length = pkgs.image-builder.helpers.size.MiB 4;
          }
          {
            name = "mn-boot";
            partitionLabel = "boot";
            partitionUUID = "CFB21B5C-A580-DE40-940F-B9644B4466E1";
            bootable = true;
            raw = boot-partition;
          }
        ];
      };
      mobile.generatedFilesystems.boot = {
        filesystem = "fat32";
        label = mkDefault "BOOT";
        # Let's give us a *bunch* of space to play around.
        # And let's not forget we have the kernel and stage-1 twice.
        size = pkgs.image-builder.helpers.size.MiB 128;

        fat32.partitionID = "ABADF00D";
        populateCommands = ''
          mkdir -vp System/Boot
          (
          set -x
          cd System/Boot
          cp -v ${stage-0.mobile.outputs.initrd} stage-1
          cp -v ${kernel_file} kernel
          mkdir -p dtbs/amlogic
          cp -t dtbs/amlogic -v ${kernel}/dtbs/amlogic/meson-g12b*odroid-go*.dtb
          cp -t dtbs/amlogic -v ${kernel}/dtbs/amlogic/meson-g12b*powkiddy*.dtb
          )
          cp -v ${bootini} ./boot.ini
        '';
      };
      mobile.outputs = {
        default = config.mobile.outputs.odroid-style.disk-image;
        odroid-style = {
          inherit bootini;
          inherit boot-partition;
          disk-image = config.mobile.generatedDiskImages.disk-image.output;
        };
      };
    })
  ];
}
