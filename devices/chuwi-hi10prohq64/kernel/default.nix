{
  mobile-nixos
, fetchFromGitHub
, fetchpatch
, kernelPatches ? [] # FIXME
}:

# FIXME use the known good revision
mobile-nixos.kernel-builder {
  version = "5.10.0-rc6";
  configfile = ./config.x86_64;

  src = fetchFromGitHub {
    owner = "jwrdegoede";
    repo = "linux-sunxi";
    rev = "b6fc1d687f8ca99c45deb8a8d9d8097cc96dd91e";
    sha256 = "0fr9y4al7xg4wfan0v1r3a7fp17cbll2vabi36bcjal2k78xrrq3";
  };

  patches = [
    ./0001-HACK-Bake-in-touchscreen-tranformation-matrix.patch
    ./0001-rtl8723bs-Allow-building-into-the-kernel.patch
  ];

  # The author keeps their config in the tree :/
  prePatch = ''
    rm -f .config
  '';

  isCompressed = false;
}
