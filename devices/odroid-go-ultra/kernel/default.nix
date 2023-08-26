{ mobile-nixos
, fetchFromGitHub
, ...
}:

mobile-nixos.kernel-builder {
  version = "6.1.45";
  configfile = ./config.aarch64;

  src = builtins.fetchGit /Users/samuel/tmp/linux/jelos-g12b-gaming-devices;
  ## Re-hydration of a community-found history-less dump.
  #src = fetchFromGitHub {
  #  owner = "samueldr";
  #  repo = "linux";
  #  rev = "f896b443d61b8d17babb6b8f00a3a0efd88b2905"; # wip/rg351p-games-os
  #  sha256 = "";
  #};

  isModular = false;
  isCompressed = false;
}
