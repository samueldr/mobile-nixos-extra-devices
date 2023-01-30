{ stdenv
, lib

, fetchFromGitHub

, withAssets ? true
, withCoreInfo ? true
, withWayland  ? stdenv.isLinux

, libretro-core-info
, retroarch-assets

, SDL2
, alsa-lib
, dbus
, fetchpatch
, flac
, freetype
, libGL
, libGLU
, libdrm
, libpulseaudio
, libxkbcommon
, libxml2
, mbedtls_2
, mesa
, udev
, wayland
, zlib

, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "retroarch-bare";
  version = "1.14.0";

  src = builtins.fetchGit {
    url = ~/Projects/celun/wip-games-os/projects/RetroArch;
  };
  ##src = fetchFromGitHub {
  ##  owner = "libretro";
  ##  repo = "RetroArch";
  ##  hash = "sha256-oEENGehbzjJq1kTiz6gkXHMMe/rXjWPxxMoe4RqdqK4=";
  ##  rev = "v${version}";
  ##};

  patches = [
    ./use-default-values-for-libretro_info_path-assets_directory.patch
    # TODO: remove those two patches in the next RetroArch release
    (fetchpatch {
      url = "https://github.com/libretro/RetroArch/commit/894c44c5ea7f1eada9207be3c29e8d5c0a7a9e1f.patch";
      hash = "sha256-ThB6jd9pmsipT8zjehz7znK/s0ofHHCJeEYBKur6sO8=";
    })
    (fetchpatch {
      url = "https://github.com/libretro/RetroArch/commit/c5bfd52159cf97312bb28fc42203c39418d1bbbd.patch";
      hash = "sha256-rb1maAvCSUgq2VtJ67iqUY+Fz00Fchl8YGG0EPm0+F0=";
    })
  ];

  nativeBuildInputs = [
    pkg-config
  ]
    ++ lib.optional withWayland wayland
  ;

  buildInputs = [
    flac
    freetype
    libGL
    libGLU
    libxml2
    mbedtls_2
    SDL2
    zlib
  ] ++
  lib.optional withWayland wayland ++
  lib.optionals stdenv.isLinux [
    alsa-lib
    dbus
    libdrm
    libpulseaudio
    libxkbcommon
    mesa
    udev
  ];

  enableParallelBuilding = true;

  makeFlags = [
    "HAVE_SHUTDOWN=1"
    "HAVE_GOCFW=1"
  ];

  configureFlags =
    [
      # Library purity
      "--enable-systemmbedtls"
      "--disable-builtinmbedtls"
      "--disable-update_cores"
      "--disable-builtinzlib"
      "--disable-builtinflac"

      # Features that don't make sense
      "--disable-update_cores"
      "--disable-discord"
      "--disable-ffmpeg"
      "--disable-x11"

      # Frameworks and libs that don't apply here
      "--disable-qt"
      "--disable-sdl"
      "--disable-mali_fbdev"
      "--disable-opengl"
      "--disable-opengl1"
      "--disable-vg"
      "--disable-vulkan"
      "--disable-vulkan_display"

      # Basic fraemworks and libs in use
      "--enable-wayland"
      "--enable-alsa"
      "--enable-egl"
      "--enable-kms"
      "--enable-opengles"
      "--enable-opengles3"
      "--enable-opengles3_2"
      "--enable-freetype"
      "--enable-sdl2"
      "--enable-udev"
      "--enable-zlib"
    ]
    ++ lib.optionals withAssets [
      "--disable-update_assets"
      "--with-assets_dir=${retroarch-assets}/share"
    ]
    ++ lib.optionals withCoreInfo [
      "--disable-update_core_info"
      "--with-core_info_dir=${libretro-core-info}/share"
    ]
  ;

  meta = {
    platforms = lib.platforms.unix;
  };
}
