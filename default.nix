{ mobile-nixos ? <mobile-nixos>
, device ? null
}:

let
  deviceConfig = ./. + "/devices/${device}/default.nix";
in

if device == null then
  throw "A device must be given, try adding `--argstr device device-name`."
else if !(builtins.pathExists deviceConfig) then
  throw "The device '${device}' could not be found."
else if !(builtins.tryEval (builtins.pathExists mobile-nixos)).value then
  throw "Mobile NixOS needs to be provided either through NIX_PATH or as an argument."
else
import (mobile-nixos) { device = deviceConfig; }
