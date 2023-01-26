{ mobile-nixos
, fetchFromGitHub
, ...
}:

mobile-nixos.kernel-builder {
  version = "4.4.189";
  configfile = ./config.aarch64;

  # Re-hydration of a community-found history-less dump.
  src = fetchFromGitHub {
    owner = "samueldr";
    repo = "linux";
    rev = "7aa0ebcf5560eb05aa1d5acb40373a2c42f5e37f"; # wip/rg351p-games-os
    sha256 = "sha256-VF3eb+vfefH7eViYDSfwvvg0eokAApeTTmE2Y+3qUR8=";
  };

  isModular = false;
  isCompressed = false;
}
