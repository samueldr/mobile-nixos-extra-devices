Pine64 PINEBOOK Pro
===================

Usage
-----

Example building `examples/hello`

```
 $ nix-build \
    --arg device ./devices/pine64-pinebookpro \
	../mobile-nixos/examples/hello/ \
	-A build.default
 $ lsblk /dev/mmcblk0 && sudo dd if=result of=/dev/mmcblk0 bs=8M status=progress oflag=sync
```

(You may want to add a nixpkgs to your NIX_PATH or -I for a proper nixpkgs)

The SD image produced is self-contained, and should boot on the device as long
as the SoC's boot order or the running u-boot's boot order allows it.
