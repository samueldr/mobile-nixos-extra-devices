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


DNX Fastboot mode
-----------------

This tablet, and possibly other "trail" Intel tablets, support the *DNX
Fastboot mode*.

While it is intended to be used with the proprietary Intel flashing tool, it
has been observed that when connected using the **type-c** USB port, `fastboot`
is available.

Most `fastboot` commands fail in *DNX Fastboot*. While I haven't dug in the
sources to confirm, it seems only `fastboot boot` works.

`fastbot boot` in *DNX Fastboot* seems to be built with the goal of booting
EFI programs. Though booting arbitrary programs seems to fail.

It may be that they need [a magic string](https://github.com/intel/kernelflinger/blame/68485596d98c23fde6b92c9b215b9d3a925d7ae0/kernelflinger.c#L76-L77)
to be embedded in the bootloader to proceed.

You can boot the vendor's *kernelflinger* build, which is available in the
*Hi10 Pro Android (after 201703XXXXX).rar* archive, as `loader.efi`.

Launching *kernelflinger* that way will launch it in fastboot mode directly.
This, in turn, gives a full fastboot environment to interact with the tablet.
Do note that [there are useful extensions](https://github.com/intel/kernelflinger/blob/master/doc/fastboot.md).

Using *DNX Fastboot*, chainloading to *kernelflinger*, finally chainloading to
an appropriate boot.img, it is possible to provision the tablet from another
computer. For example, using the *target disk mode* of Mobile NixOS, one could
flash a pre-built UEFI disk image.


Boot modes
----------

The BIOS is weird. It has this weird menu which allows you to select whether
it boots in *Android* or *Windows* mode.

Selecting either mode *will change the DSDT of the device*. In turn, when
booted in *Windows* mode, the OTG interface will not be available at all. To
use USB gadget mode under Linux (to e.g. use rndis or target disk mode) you
should select the android boot mode.

To boot external drives in android mode, it might be judicious to install
*rEFInd* at the default fallback UEFI location, and let it deal with boot
options.

You can disable this menu, and boot in android mode, by using those commands:

```
$ sudo -i
# chattr -i /sys/firmware/efi/efivars/BootSelectVariable-944fb13b-773f-4cbb-9c6f-326cebde4c23
# printf '\x07\x00\x00\x00\x2a\x00\x00\x00' > /sys/firmware/efi/efivars/BootSelectVariable-944fb13b-773f-4cbb-9c6f-326cebde4c23
```


Booting *kernelflinger*
-----------------------

If you're using *rEFInd* (you probably should), drop `loader.efi` on the ESP
and select it in *rEFInd*. By default it will fail to boot, since it is looking
for the partitions via UUID. This is normal. Press up both times it is asked of
you. It will then be in fastboot mode.

You could also configure *rEFInd* to add the `-f` command-line option, this
would make the loader directly go to fastboot mode.

Using *kernelflinger* to boot the final operating system is not necessary, and
might even be a dumb (but fun?) idea. Though, using *kernelflinger* to get
fastboot on the tablet is a great idea.


External notes
--------------

 - https://github.com/danielotero/linux-on-hi10
 - https://github.com/floe/tuxblet
 - https://github.com/brazenwinter/chuwihi10prolinux

### About other variants of the Hi10 Pro

 - https://github.com/willyneutron/lubuntu_in_chuwi_Hi10Pro
