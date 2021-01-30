{
  mobile-nixos
, fetchFromGitLab
, ...
}:

mobile-nixos.kernel-builder {
  version = "5.10.0-rc5";
  configfile = ./config.aarch64;

  src = fetchFromGitLab {
    domain = "gitlab.manjaro.org";
    owner = "tsys";
    repo = "linux-pinebook-pro";
    rev = "c04087388bdb7d79d5202ffb91aa387e36901056";
    sha256 = "0igxbq8i0z6qs1kxxxs440d1n1j5p5a26lgcn7q5k82rdjqhwpw9";
  };

  patches = [
    ./0001-HACK-Revert-pwm-Read-initial-hardware-state-at-reque.patch
    ./0001-arm64-dts-rockchip-set-type-c-dr_mode-as-otg.patch
    ./0001-usb-dwc3-Enable-userspace-role-switch-control.patch
  ];

  postInstall = ''
    echo ":: Installing FDTs"
    mkdir -p $out/dtbs/rockchip
    cp -v "$buildRoot/arch/arm64/boot/dts/rockchip/rk3399-pinebook-pro.dtb" "$out/dtbs/rockchip/"
  '';

  isModular = false;
  isCompressed = false;
}
