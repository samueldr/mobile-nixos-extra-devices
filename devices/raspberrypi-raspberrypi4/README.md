Raspberry Pi Foundation Raspberry Pi 4 Model B
==============================================

Usage
-----

Example building `examples/hello`

```
 $ nix-build \
    --arg device ./devices/raspberrypi-raspberrypi4 \
	../mobile-nixos/examples/hello/ \
	-A build.default
 $ lsblk /dev/mmcblk0 && sudo dd if=result/mobile-nixos.img of=/dev/mmcblk0 bs=8M status=progress oflag=sync
```

(You may want to add a nixpkgs to your NIX_PATH or -I for a proper nixpkgs)

The image is self-contained, and should boot either from SD or USB, as long as
the EEPROM configuration of the Raspberry Pi 4 has been configured appropriately.
