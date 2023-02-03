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
  };
  config = mkIf (config.wip.retroarch.squashfs.enable) {
    fileSystems =
      let
        tmpfsConf = {
          device = "tmpfs";
          fsType = "tmpfs";
          neededForBoot = true;
        };
      in
      {
        "/" = mkDefault {
          autoResize = mkForce false;
          fsType = mkForce config.mobile.generatedFilesystems.rootfs.filesystem;
          device = mkForce "/dev/sda2";
        };

        "/userdata" = {
          device = "/dev/disk/by-label/${config.mobile.generatedFilesystems.boot.label}";
          fsType = "vfat";
          # Or else activation script will fail with tmpfiles.d attempting to seed it. :/
          neededForBoot = true;
        };

        "/etc" = tmpfsConf;
        "/run" = tmpfsConf;
        "/tmp" = tmpfsConf;
        "/nix/var" = tmpfsConf;

        "/var" = tmpfsConf;

        "/root" = tmpfsConf;
        "/home" = tmpfsConf;
      }
    ;
    mobile.boot.stage-1 = {
      kernel.additionalModules = [
        "squashfs"
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
    };
  };
}
