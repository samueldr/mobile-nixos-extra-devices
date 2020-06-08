{
  mobile-nixos
, fetchFromGitHub
, fetchpatch
, kernelPatches ? [] # FIXME
, cpio
}:

(mobile-nixos.kernel-builder rec {
  version = "5.4.42";
  configfile = ./config.aarch64;
  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "linux";
    rev = "971a2bb14b459819db1bda8fcdf953e493242b42"; # raspberrypi-kernel_1.20200601+arm64-1
    sha256 = "07zlzhz4v9vlq2p7b7lgphmkf9vch5nm627rvmccsy8qjaxpypmd";
  };
  patches = [
    ./0001-ASoC-cs42xx8-Fix-building-built-in.patch
  ];
}).overrideAttrs({ postInstall ? "", postPatch ? "", nativeBuildInputs, ... }: {
  nativeBuildInputs = nativeBuildInputs ++ [ cpio ];
  installTargets = [ "install" "dtbs" ];
  postInstall = postInstall + ''
    mkdir -p $out/dtbs/broadcom
    cp -v "$buildRoot/arch/arm64/boot/dts/broadcom/"bcm*.dtb "$out/dtbs/broadcom/"
  '';
})
