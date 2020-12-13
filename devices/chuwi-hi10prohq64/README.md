CHUWI Hi10 Pro (HQ64)
=====================

Usage
-----

Example building `examples/hello`

```
 $ nix-build \
    --arg device ./devices/chuwi-hi10prohq64 \
	../mobile-nixos/examples/hello/ \
	-A build.default
 $ lsblk /dev/sdX && sudo dd if=result of=/dev/sdX bs=8M status=progress oflag=sync
```

(You may want to add a nixpkgs to your NIX_PATH or -I for a proper nixpkgs)
