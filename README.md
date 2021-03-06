Extra Devices
=============

> Why aren't those devices part of the main Mobile NixOS repository?

They are either experimental, or do not fit the goal of abstracting the
"mobile" segment of devices.

In other words, probably because they're not phones or tablets.

How to use this repository
--------------------------

The `default.nix` proxies this repository's devices to the `default.nix` from
the main Mobile NixOS repository as given.

This file is provided as a convenience.

```
.../Projects/extra-devices $ nix-build \
    -I mobile-nixos=.../Projects/mobile-nixos/ \
    --argstr device device-name \
    -A build.default
```

This, though, does not trivially allow re-using the Mobile NixOS examples.

Another options is to pass the *path* to the device directory to an invocation
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

The second usage is more likely to be the one you end up using.


### Alternative usage

Users may want to symlink the device folders into their Mobile NixOS checkout.
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
