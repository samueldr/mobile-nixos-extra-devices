{ lib
, runCommandNoCC
, fetchFromGitHub
, firmwareLinuxNonfree
}:


let
  gsl-firmware = fetchFromGitHub {
    owner = "onitake";
    repo = "gsl-firmware";
    rev = "f547ae83770babc2d425ba3759c3fa43fc018a17";
    sha256 = "11b5dwj0mqa4p6psznj8nvir63i1zaz4f5vfl3dgykpq2p4jwkxg";
  };
in

# The minimum set of firmware files required for the device.
runCommandNoCC "chuwi-hi10prohq64-firmware" {} ''
  echo "-> Copying silead firmware"
  mkdir -p $out/lib/firmware/silead
  (cd ${gsl-firmware}
  cp -v firmware/chuwi/hi10_pro-z8350/firmware.fw $out/lib/firmware/silead/mssl1680.fw
  )

  echo "-> Copying from firmwareLinuxNonfree"
  for firmware in \
    intel/fw_sst_22a8.bin \
    rtl_bt/rtl8723bs_config-OBDA8723.bin \
    rtl_bt/rtl8723bs_fw.bin \
    rtlwifi/rtl8723bs_ap_wowlan.bin \
    rtlwifi/rtl8723bs_bt.bin \
    rtlwifi/rtl8723bs_nic.bin \
    rtlwifi/rtl8723bs_wowlan.bin \
  ; do
    mkdir -p "$(dirname $out/lib/firmware/$firmware)"
    cp -vrf "${firmwareLinuxNonfree}/lib/firmware/$firmware" $out/lib/firmware/$firmware
  done
''
