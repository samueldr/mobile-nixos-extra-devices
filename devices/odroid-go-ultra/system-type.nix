{ config, pkgs, lib, ... }:

let
  enabled = config.mobile.system.type == "odroid-go-ultra-style";

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

  bootini = pkgs.writeText "${deviceName}-boot.ini" ''
    ODROIDGOU-UBOOT-CONFIG

    setenv bootargs ${lib.concatStringsSep " " config.boot.kernelParams}

    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"

    setenv fdt_addr_r     "0x10000000"
    setenv ramdisk_addr_r "0x11000000"
    setenv kernel_addr_r  "0x1b00000"

    load mmc ''${devno}:1 ''${kernel_addr_r}   /System/Boot/kernel
    load mmc ''${devno}:1 ''${fdt_addr_r}      /System/Boot/dtbs/amlogic/''${fdtfile}
    load mmc ''${devno}:1 ''${ramdisk_addr_r}  /System/Boot/stage-1
    setenv ramdisk_size ''${filesize}

    fdt addr ''${fdt_addr_r}

    # Eh...
    fdt resize 1024
    fdt mknode / mobile-nixos
    fdt set    /mobile-nixos device-name ${deviceName}

    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo booti ''${kernel_addr_r} ''${ramdisk_addr_r}:''${ramdisk_size} ''${fdt_addr_r}
    booti ''${kernel_addr_r} ''${ramdisk_addr_r}:''${ramdisk_size} ''${fdt_addr_r}
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo ""
    echo "booti failure..."
    echo ""
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
  '';
in
{
  options.mobile = {
    outputs = {
      odroid-go-ultra-style = {
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
    { mobile.system.types = [ "odroid-go-ultra-style" ]; }
    (mkIf enabled {
      mobile.generatedDiskImages.disk-image = {
        partitioningScheme = "mbr"; # [sic]
        partitions = mkBefore [
          {
            name = "u-boot";
            # XXX build U-Boot ourselve...
            raw = ./u-boot.bin;
            offset = 512;
            #length = pkgs.image-builder.helpers.size.MiB 4;
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
        default = config.mobile.outputs.odroid-go-ultra-style.disk-image;
        odroid-go-ultra-style = {
          inherit bootini;
          inherit boot-partition;
          disk-image = config.mobile.generatedDiskImages.disk-image.output;
        };
      };
    })
  ];
}
/*

setenv fdt_addr_r     "0x10000000"
setenv ramdisk_addr_r "0x11000000"
setenv kernel_addr_r  "0x1b00000"

load mmc 1:1 ${kernel_addr_r}   /System/Boot/kernel
load mmc 1:1 ${fdt_addr_r}      /System/Boot/dtbs/amlogic/meson-g12b-odroid-go-ultra.dtb
load mmc 1:1 ${ramdisk_addr_r}  /System/Boot/stage-1
setenv ramdisk_size ${filesize}
fdt addr ${fdt_addr_r}
booti ${kernel_addr_r} - ${fdt_addr_r}
booti ${kernel_addr_r} ${ramdisk_addr_r}:${ramdisk_size} ${fdt_addr_r}


*/
