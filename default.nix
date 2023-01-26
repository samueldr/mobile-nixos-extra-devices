{ mobile-nixos ? <mobile-nixos>
, pkgs ? import (mobile-nixos + /pkgs.nix) {}
, device ? null
, configuration ? {}
}:

if !(builtins.tryEval (builtins.pathExists mobile-nixos)).value then
  throw "Mobile NixOS needs to be provided either through NIX_PATH or as an argument."
else

let deviceArg = device; in
let
  device =
    if builtins.isPath deviceArg
      then deviceArg
    else if builtins.isString deviceArg
      then ./. + "/devices/${deviceArg}/default.nix"
    else
      builtins.throw ''
        The `device` argument must be a path or a string.

        TIP: use `--argstr device device-name` for a device defined in the devices directory.
      ''
  ;
in

import (mobile-nixos + /lib/eval-with-configuration.nix) {
  inherit device;
  inherit pkgs;
  configuration = [
    configuration
  ];
}
