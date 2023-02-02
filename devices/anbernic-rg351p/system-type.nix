{ config, pkgs, lib, ... }:

let
  enabled = config.mobile.system.type == "odroid-style";

  inherit (config.mobile.outputs) recovery stage-0;
  inherit (pkgs) imageBuilder;
  inherit (lib) mkBefore mkIf mkOption types;
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

    setenv dtb_name "rk3326-rg351p-linux.dtb"

    gpio toggle a15 # on
    load mmc 1:1 ''${kernel_addr_r}   /mobile-nixos/boot/kernel
    gpio toggle a15 # off

    load mmc 1:1 ''${fdt_addr_r}      /mobile-nixos/boot/dtbs/rockchip/''${dtb_name}

    gpio toggle a15 # on
    load mmc 1:1 ''${ramdisk_addr_r} /mobile-nixos/boot/stage-1
    setenv ramdisk_size ''${filesize}
    gpio toggle a15 # off

    booti ''${kernel_addr_r} ''${ramdisk_addr_r}:''${ramdisk_size} ''${fdt_addr_r};

    sleep 0.5
    gpio toggle a15
    sleep 0.5
    gpio toggle a15
    sleep 0.5
    gpio toggle a15
    sleep 0.5
    gpio toggle a15
    sleep 0.5
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
        partitions = mkBefore [
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
        # Let's give us a *bunch* of space to play around.
        # And let's not forget we have the kernel and stage-1 twice.
        size = pkgs.image-builder.helpers.size.MiB 128;

        fat32.partitionID = "ABADF00D";
        populateCommands = ''
          mkdir -vp mobile-nixos/{boot,recovery}
          (
          cd mobile-nixos/boot
          cp -v ${stage-0.mobile.outputs.initrd} stage-1
          cp -v ${kernel_file} kernel
          mkdir -p dtbs/rockchip
          cp -t dtbs/rockchip -v ${kernel}/dtbs/rockchip/rk3326*rg351*dtb
          )
          (
          cd mobile-nixos/recovery
          cp -v ${recovery.mobile.outputs.initrd} stage-1
          cp -v ${kernel_file} kernel
          mkdir -p dtbs/rockchip
          cp -t dtbs/rockchip -v ${kernel}/dtbs/rockchip/rk3326*rg351*dtb
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
