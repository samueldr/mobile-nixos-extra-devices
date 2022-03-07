{
  mobile-nixos
, fetchurl
, ...
}:

# FIXME use the known good revision
mobile-nixos.kernel-builder rec {
  version = "5.10.103";
  configfile = ./config.x86_64;

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
    sha256 = "sha256-T7itVeZDA0Lk+8lNVOWU6b6Otqi+odcezPg1lI0IWAo=";
  };                                                            

  patches = [
    ./0001-HACK-Bake-in-touchscreen-tranformation-matrix.patch
    ./0001-rtl8723bs-Allow-building-into-the-kernel.patch
    ./0001-HACK-always-show-logo.patch
  ];

  # The author keeps their config in the tree :/
  prePatch = ''
    rm -f .config
  '';

  isCompressed = false;
}
