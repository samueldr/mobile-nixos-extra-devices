{ mobile-nixos ? <mobile-nixos>
, pkgs ? import (mobile-nixos + /pkgs.nix) {}
, device ? null
, configuration ? {}
}:

import ../../default.nix {
  inherit
    mobile-nixos
    pkgs
    device
  ;

  configuration = {
    imports = [
      configuration
      ./configuration
    ];
  };
}
