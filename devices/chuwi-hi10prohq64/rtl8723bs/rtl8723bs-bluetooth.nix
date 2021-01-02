{stdenv, lib, fetchFromGitHub, util-linux, procps}:

stdenv.mkDerivation rec {
  name = "rtl8723bs-bluetooth";

  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtl8723bs_bt";
    rev = "09eb91f52a639ec5e4c5c4c98dc2afede046cf20";
    sha256 = "0b7mvvsdsih48nb3dgknfd9xj5h38q8wyspxi7h0hynb8szjjda4";
  };

  patchPhase = ''
    substituteInPlace hciattach_rtk.c \
      --replace /lib/firmware/rtl_bt/ "$out/lib/firmware/"
  '';

  installPhase = ''
    # Copying the tool
    for file in rtk_hciattach; do
      install -Dm755 $file $out/lib/$file
    done

    # Copying the firmware
    for file in rtlbt_*; do
      install -Dm644 $file $out/lib/firmware/$file
    done

    # Copying the script
    install -Dm755 ${./start_bt.sh} $out/lib/start_bt.sh
    substituteInPlace $out/lib/start_bt.sh \
      --replace @@path@@ "${lib.makeBinPath [ util-linux procps ]}" \
      --replace @@out@@ "$out"
    patchShebangs $out/lib/start_bt.sh
  '';

  meta = with stdenv.lib; {
    description = "Userspace configuration for rtl8723bs bluetooth.";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
  };
}
