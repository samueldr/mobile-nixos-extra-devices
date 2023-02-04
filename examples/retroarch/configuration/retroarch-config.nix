{ lib, config, pkgs, ... }:

let
  inherit (lib)
    attrNames
    concatMapStringsSep
    filterAttrs
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.wip.retroarch;

  keptConfig = filterAttrs (k: v: v != null) cfg.config;
  forcedConfig = pkgs.writeText "retroarch-forced-fragment.cfg" (
    concatMapStringsSep "\n" (k:
      "${k} = ${builtins.toJSON keptConfig."${k}"}"
    ) (attrNames keptConfig)
  );

  joypadAutoconfig = pkgs.callPackage (
    { runCommand }:

    runCommand "retroarch-joypad-autoconfig" {
      src = ./retroarch/joypad_autoconfig;
    } ''
      cp -prf $src $out
    ''
  ) {};

  retroarch_stateful = "~/.config/retroarch";
  retroarch_misc = "/userdata/Data/misc/retroarch";
in
{
  options = {
    wip.retroarch = {
      wrapped = mkOption {
        type = types.package;
        internal = true;
      };
      cores = mkOption {
        type = with types; listOf package;
      };
      config = mkOption {
        type = with types; nullOr (attrsOf str);
        default = {};
        description = ''
          RetroArch options that will be forced via --appendconfig.

          Use `null` to remove a previously defined value.

          All values are strings, that is true for the configuration format too.
        '';
      };
    };
  };
  config = {
    wip.retroarch.cores = with pkgs.libretro.override { inherit (pkgs) retroarch; }; [
      beetle-pce-fast
      fceumm
      gambatte
      pcsx-rearmed
      picodrive
      snes9x2005-plus
      (gpsp.overrideAttrs({ makeFlags ? [], patches ? [], ... }: {
        makeFlags =
          let
            inherit (pkgs) stdenv;
            platforms = {
              "aarch64-linux" = "arm64";
              "x86_64-linux" = "unix";
            };
            cpuArches = {
              "aarch64-linux" = "arm64";
              "x86_64-linux" = "x86_32";
            };
          in
          makeFlags ++ [
            "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
            "CC=${stdenv.cc.targetPrefix}cc"
            "LD=${stdenv.cc.targetPrefix}cc"
            "CXX=${stdenv.cc.targetPrefix}c++"
            "AR=${stdenv.cc.bintools.targetPrefix}ar"
            "platform=${platforms."${pkgs.stdenv.system}"}"
            "CPU_ARCH=${cpuArches."${pkgs.stdenv.system}"}"
          ]
        ;
      }))
    ];
    wip.retroarch.config = {
      config_save_on_exit = "true";
      core_info_cache_enable = "false";
      joypad_autoconfig_dir = "${joypadAutoconfig}";
      screenshot_directory = "/userdata/Screenshots";
      savefile_directory   = "/userdata/Saves";
      savestate_directory  = "/userdata/Saves/state";
      rgui_browser_directory = "/userdata/Roms";

      log_dir                    = "${retroarch_stateful}/logs";
      content_favorites_path     = "${retroarch_stateful}/content_favorites.lpl";
      content_history_path       = "${retroarch_stateful}/content_history.lpl";
      content_image_history_path = "${retroarch_stateful}/content_image_history.lpl";
      content_music_history_path = "${retroarch_stateful}/content_music_history.lpl";
      content_video_history_path = "${retroarch_stateful}/content_video_history.lpl";
      cursor_directory           = "${retroarch_stateful}/database/cursors";
      content_database_path      = "${retroarch_stateful}/database/rdb";
      input_remapping_directory  = "${retroarch_stateful}/config/remaps";
      playlist_directory         = "${retroarch_stateful}/playlists";
      recording_config_directory = "${retroarch_stateful}/records_config";
      recording_output_directory = "${retroarch_stateful}/records";
      rgui_config_directory      = "${retroarch_stateful}/config";
      thumbnails_directory       = "${retroarch_stateful}/thumbnails";

      # Probably not feasible in a useful manner.
      # We probably want a base skeleton we can ship with the image instead.
      # core_options_path = "???";
      # global_core_options = "???";

      audio_filter_dir       = "${retroarch_misc}/filters/audio";
      cheat_database_path    = "${retroarch_misc}/cheats";
      core_assets_directory  = "${retroarch_misc}/downloads";
      overlay_directory      = "${retroarch_misc}/overlay";
      system_directory       = "${retroarch_misc}/system";
      video_filter_dir       = "${retroarch_misc}/filters/video";
      video_layout_directory = "${retroarch_misc}/layouts";
      video_shader_dir       = "${retroarch_misc}/shaders";

      # allow any RetroPad to control the menu
      all_users_control_menu = "true";

      # RetroPad button combination to toggle menu
      # 0: None
      # 1: Down + Y + L1 + R1
      # 2: L3 + R3
      # 3: L1 + R1 + Start + Select
      # 4: Start + Select
      # 5: L3 + R1
      # 6: L1 + R1
      # 7: Hold Start (2 seconds)
      # 8: Hold Select (2 seconds)
      # 9: Down + Select
      # 10: L2 + R2
      # NOTE: we're mapping L1+R1+START+SELECT as a fallback.
      #       the supported bind is select as hotkey, with start for menu.
      input_menu_toggle_gamepad_combo = "3";

      # RetroPad button combination to quit
      # 0: None
      # 1: Down + Y + L1 + R1
      # 2: L3 + R3
      # 3: L1 + R1 + Start + Select
      # 4: Start + Select
      # 5: L3 + R1
      # 6: L1 + R1
      # 7: Hold Start (2 seconds)
      # 8: Hold Select (2 seconds)
      # 9: Down + Select
      # 10: L2 + R2
      input_quit_gamepad_combo = "0";

      fps_show = "false";
      memory_show = "false";

      settings_show_accessibility = "true";
      settings_show_audio = "true";
      settings_show_configuration = "true";
      settings_show_core = "true";
      settings_show_directory = "true";
      settings_show_drivers = "true";
      settings_show_file_browser = "true";
      settings_show_frame_throttle = "true";
      settings_show_input = "true";
      settings_show_latency = "true";
      settings_show_logging = "true";
      settings_show_onscreen_display = "true";
      settings_show_playlists = "true";
      settings_show_power_management = "true";
      settings_show_recording = "true";
      settings_show_saving = "true";
      settings_show_user = "true";
      settings_show_user_interface = "true";
      settings_show_video = "true";

      settings_show_network = "false";
      settings_show_achievements = "false";
      settings_show_ai_service = "false";

      content_show_add = "true";
      content_show_explore = "true";
      content_show_history = "true";
      content_show_settings = "true";
      content_show_add_entry = "2";
      #content_show_contentless_cores = "0";

      content_show_favorites = "false";
      content_show_images = "false";
      content_show_music = "false";
      content_show_netplay = "false";
      content_show_playlists = "false";
      content_show_video = "false";
      # content_show_settings_password = "";

      menu_show_advanced_settings = "true";
      menu_show_configurations = "false";
      menu_show_core_updater = "false";
      menu_show_dump_disc = "false";
      menu_show_help = "false";
      menu_show_information = "true";
      menu_show_latency = "true";
      menu_show_legacy_thumbnail_updater = "false";
      menu_show_load_content = "true";
      menu_show_load_content_animation = "true";
      menu_show_load_core = "true";
      menu_show_load_disc = "false";
      menu_show_online_updater = "false";
      menu_show_overlays = "false";
      menu_show_quit_retroarch = "false";
      menu_show_reboot = "true";
      menu_show_rewind = "true";
      menu_show_shutdown = "true";
      menu_show_sublabels = "true";
      menu_show_video_layout = "false";
      # Restart is buggy on some platforms and undesirable UX-wise...
      menu_show_restart_retroarch = "false";
    };
    wip.retroarch.wrapped = pkgs.callPackage (
      { symlinkJoin
      , retroarch
      , selectedRetroArchCores
      , forcedConfig
      }:
      symlinkJoin {
        name = "retroarch-wrapped";
        paths = selectedRetroArchCores;
        postBuild = ''
          mkdir -p $out/bin
          cat <<EOF > $out/bin/retroarch
          #!/bin/sh
          exec -a retroarch \
            ${retroarch}/bin/retroarch \
            --libretro=${placeholder "out"}/lib/retroarch/cores \
            --appendconfig=${forcedConfig} \
            "\$@"
          EOF
          chmod +x $out/bin/retroarch
        '';
      }
    ) {
      selectedRetroArchCores = cfg.cores;
      inherit forcedConfig;
    };
    systemd.tmpfiles.rules = [
      "d /userdata/Data/misc/retroarch 0770 games users"
      "d /userdata/Roms 0770 games users"
      "d /userdata/Saves 0770 games users"
      "d /userdata/Saves/state 0770 games users"
    ];
  };
}
