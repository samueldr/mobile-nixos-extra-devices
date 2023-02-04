{ config, lib, pkgs, ... }:

let
  inherit (lib)
    concatMapStringsSep
    escapeShellArg
    mkAfter
    mkBefore
    mkDefault
    mkForce
    mkIf
    mkOption
    types
  ;
  inherit (pkgs.image-builder.helpers) size;
  deviceName = config.mobile.device.name;
  name = "${config.mobile.configurationName}-${deviceName}";
  boot-partition = config.mobile.generatedFilesystems.boot.output;
in
{
  options = {
    wip.retroarch.squashfs = {
      enable = mkOption {
        default = true;
        type = types.bool;
        description = ''
          Use squashfs rootfs.

          This is a hack.
        '';
      };
    };
    wip.retroarch.outputs = {
      systemFiles = mkOption {
        type = types.package;
        description = ''
          Contents that would be at the root of the target filesystem.
        '';
      };
    };
  };
  config = mkIf (config.wip.retroarch.squashfs.enable) {
    fileSystems =
      let
        tmpfsConf = {
          device = "tmpfs";
          fsType = "tmpfs";
          neededForBoot = true;
        };
        bind = { from, to }: {
          "${to}" = {
            device = from;
            options = [ "bind" ];
          };
        };
      in
      {
        "/" = mkDefault {
          autoResize = mkForce false;
          fsType = mkForce config.mobile.generatedFilesystems.rootfs.filesystem;
          device = mkForce "/dev/rootfs";
          options = [
            "loop"
          ];
        };

        "/userdata" = {
          device = "/dev/disk/by-label/${config.mobile.generatedFilesystems.boot.label}";
          fsType = "vfat";
          # Or else activation script will fail with tmpfiles.d attempting to seed it. :/
          neededForBoot = true;
          options = [
            # A bit wild, but this is FAT32 we're talking about
            "umask=0000"
            "fmask=0000"
            "dmask=0000"
            # Unneeded really since we gave everyone write access
            "uid=1000"
            "gid=100"

            # No.
            "nosuid"
            "nodev"
            "noatime"
          ];
        };

        "/etc" = tmpfsConf;
        "/run" = tmpfsConf;
        "/tmp" = tmpfsConf;
        "/nix/var" = tmpfsConf;
        "/var" = tmpfsConf;

        "/root" = tmpfsConf;
        "/home" = tmpfsConf;
      }
      // bind { from = "/userdata/Data/stateful/log"; to = "/var/log"; }
    ;
    mobile.boot.stage-1 = {
      kernel.additionalModules = [
        "squashfs"
        "loop"
      ];
    };
    mobile.generatedFilesystems.rootfs = mkDefault {
      filesystem = mkForce "squashfs";
      populateCommands = mkAfter ''
        ${concatMapStringsSep "\n" (dir: "mkdir -p ${escapeShellArg dir}")  [
          "etc"
          "home"
          "run"
          "tmp"
          "var"
          "nix/var"

          "dev"
          "proc"
          "sys"

          "userdata"
          "root"
          "home"
        ]}

        mkdir -p bin
        ln -s ${config.system.build.binsh}/bin/sh bin/sh
        mkdir -p usr/bin
        ln -s ${pkgs.coreutils}/bin/env usr/bin/env
      '';
    };
    mobile.generatedFilesystems.boot = {
      label = mkForce "USERDATA";
      size = mkForce (size.GiB 1);
      populateCommands = mkAfter ''
        mkdir -p System
        cp ${config.mobile.generatedFilesystems.rootfs.imagePath} System/rootfs.img
      '';
    };
    mobile.generatedDiskImages.disk-image = {
      partitions = mkForce [
        {
          name = "userdata";
          partitionLabel = "userdata";
          partitionUUID = "CFB21B5C-A580-DE40-940F-B9644B4466E1";
          bootable = true;
          raw = boot-partition;
        }
      ];
    };

    mobile.boot.stage-1.tasks = [
      # Workaround for /var/log bind mount depending on a directory that
      # may not exist.
      # /var/log is forced to be marked as needed for boot in NixOS.
      (pkgs.writeText "var-log.rb" ''
        class Tasks::VarLogBoundDir < SingletonTask
          TARGET = ${builtins.toJSON config.fileSystems."/var/log".device}
          def initialize()
            add_dependency(:Mount, "/mnt/userdata")
          end
          def run()
            FileUtils.mkdir_p(TARGET)
          end
        end
      '')
      (pkgs.writeText "dev-rootfs.rb" ''
        class Tasks::DevRootFS < SingletonTask
          DEVICE = ${builtins.toJSON config.fileSystems."/".device}
          SOURCE = ${builtins.toJSON config.fileSystems."/userdata".device}
          TARGET = "/userdata"
          def initialize()
            add_dependency(:Mount, "/dev")
            add_dependency(:Files, SOURCE)
          end

          def run()
            FileUtils.mkdir_p(TARGET)
            System.mount(
              SOURCE, TARGET,
              type: ${builtins.toJSON config.fileSystems."/userdata".fsType},
              options: ${builtins.toJSON config.fileSystems."/userdata".options},
            )
            File.symlink(File.join(TARGET, "System/rootfs.img"), DEVICE)
          end
        end
      '')
    ];

    wip.retroarch.outputs.systemFiles = pkgs.runCommand "${name}-system-files" {} ''
      mkdir -p $out
      (cd $out
      ${config.mobile.generatedFilesystems.boot.populateCommands}
      )
    '';
  };
}
