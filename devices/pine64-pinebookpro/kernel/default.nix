{
  mobile-nixos
, fetchFromGitLab
, fetchpatch
, kernelPatches ? [] # FIXME
}:

(mobile-nixos.kernel-builder {
  version = "5.8.0-rc1";
  configfile = ./config.aarch64;
  src = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "linux-pinebook-pro";
    rev = "57cc0e9636c160cbae5845cedf0d463e87a6023c";
    sha256 = "1j7xlclm4zmgsp5dkgzrhhjmkrg7xvqlgdz5zlj0g1g7xpxg9cwc";
  };
  patches = [
    ./0001-HACK-Revert-pwm-Read-initial-hardware-state-at-reque.patch
  ];
}).overrideAttrs({ postInstall ? "", postPatch ? "", ... }: {
  installTargets = [ "install" "dtbs" ];
  postInstall = postInstall + ''
    mkdir -p $out/dtbs/rockchip
    cp -v "$buildRoot/arch/arm64/boot/dts/rockchip/rk3399-pinebook-pro.dtb" "$out/dtbs/rockchip/"
  '';
})

