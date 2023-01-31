{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
  ;
in
{
  config = mkIf (config.mobile.device.name == "anbernic-rg351p") {
    systemd.services.rg351p-js2xbox = {
      wantedBy = [
        "games-session.service"
        "graphical.target"
      ];
      enable = true;
      script = ''
        exec ${pkgs.rg351p-js2xbox}/bin/rg351p-js2xbox --silent -t oga_joypad
      '';
    };

    systemd.services.rg351p-headphone-detect = {
      wantedBy = [
        "multi-user.target"
      ];
      enable = true;
      script = ''
        _set_path() {
          printf "Switching audio to '%s'\n" "$1"
          ${pkgs.alsa-utils}/bin/amixer cset name='Playback Path' "$1"
        }
        _set_path SPK
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };

    wip.retroarch.config = {
      # Keybinds
      input_enable_hotkey_btn = "10";        # Select
      input_menu_toggle_btn = "15";          # Start
      input_load_state_btn = "4";            # L1
      input_save_state_btn = "5";            # R1
      input_screenshot_btn = "6";            # UP
      input_state_slot_decrease_btn = "13";  # L2
      input_state_slot_increase_btn = "12";  # R2
      input_toggle_fast_forward_btn = "1";   # A
      input_fps_toggle_btn = "2";            # X
      input_toggle_statistics_btn = "7";     # Down

      # Otherwise a word pretty much doesn't fit :/
      video_font_size = "12.000000";

      input_driver = "udev";
      input_joypad_driver = "udev";
      audio_driver = "alsa";
      audio_enable = "true";
      video_threaded = "true";
      video_vsync = "true";
    };

    powerManagement.cpuFreqGovernor = "performance";
    systemd.tmpfiles.rules = [
      "w- /sys/devices/system/cpu/cpufreq/policy0/scaling_governor - - - - performance"
      "w- /sys/devices/platform/ff400000.gpu/devfreq/ff400000.gpu/governor - - - - performance"
      "w- /sys/devices/platform/dmc/devfreq/dmc/governor - - - - performance"
    ];
  };
}
