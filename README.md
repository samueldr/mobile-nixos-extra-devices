Extra Devices
=============

> Why aren't those devices part of the main Mobile NixOS repository?

They are either experimental, or do not fit the goal of abstracting the
"mobile" segment of devices.

In other words, probably because they're not phones or tablets.

How to use this repository
--------------------------

The `default.nix` in this repository will evaluate the system appropriately
against a given Mobile NixOS repository. This file is provided as a convenience.

```
.../Projects/extra-devices $ nix-build \
    --arg mobile-nixos ../mobile-nixos \
    --argstr device anbernic-rg351p \
    -A outputs.default
```

By abusing knowledge of how example systems in Mobile NixOS are built, we can
use the `configuration` argument to pass the entry point configuration of the
example system.

```
.../Projects/extra-devices $ nix-build \
    --arg mobile-nixos ../mobile-nixos \
	--argstr device anbernic-rg351p \
	--arg configuration ../mobile-nixos/examples/hello/configuration.nix \
	-A outputs.default
```

### Alternative usage

Another option is to pass the *path* to the device directory to an invocation
of the usual Mobile NixOS.

```
.../Projects/extra-devices $ nix-build \
    --arg device .../extra-devices/device-name \
    ../mobile-nixos/examples/hello/ \
    -A build.default
trace: **************************************************************
trace: * Evaluating device from path: .../extra-devices/device-name *
trace: **************************************************************
...
```

Alternatively, users may want to symlink the device folders into their
Mobile NixOS checkout.

The main benefit is that they now act just like built-in devices, including
working `bin/kernel-normalize-config`.


Implementation details
----------------------

The device files in this repository will import the modules-list for additional
options. Mostly those options will define missing quirks or hardware.

This is the main magic that is happening to automatically merge the added
options to the main Mobile NixOS repository. No magic, only imports.


Non-Goals
---------

This repository will **not** be a staging grounds for WIP ports. It is
exclusively used for experimenting.

Which means that if you have devices to contribute to this repository, think
carefully, it's probably meant for upstream if your device is a phone or a
tablet. If it isn't, fork this repo, remove what you don't need and make your
own extra devices!

Though, this does not mean I don't want contributions. If you have worthwhile
contributions to these devices, or to the experiments, feel free to contribute.

Note that it is possible that this repository drifts and becomes incompatible
with Mobile NixOS. If it does, it is a bug, it should be fixed, but there is
no SLA. It might stay broken forever.

Example reasons why devices here shouldn't be in Mobile NixOS:

 - CHUWI Hi10 Pro HQ64 build may be extremely device-specific (baked-in touchscreen calibration) and anyway barely useable.
 - Pinebook Pro is not a mobile device, served as an integration target for assumptions about the RK3399 and TDM testing.
 - Anbernic RG351P is kinda mobile, but not a phone, not a tablet, no touchscreen. This here is more a show of force about integrating really *odd* devices within the build system.
