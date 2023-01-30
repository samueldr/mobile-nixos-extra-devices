{ config, lib, pkgs, ... }:

let
  null-package = pkgs.callPackage (
    { runCommand }:
    runCommand "null-package" {} ''
      mkdir $out
    ''
  ) {};
in
{
  # Override stage-0 support for this example app.
  # It's only noise, and the current stage-0 is not able to boot anything else
  # than a system it was built for anyway.
  mobile.quirks.supportsStage-0 = lib.mkForce false;

  # Skip a long-running build for the documentation HTML.
  documentation.enable = false;

  # We don't need Nix on-device
  nix.enable = false;

  # And no NixOs containers
  boot.enableContainers = false;

  # (See nixos/modules/config/system-path.nix)
  programs.ssh.package = null-package;
  environment.defaultPackages = [];

  # Disable console things
  console.enable = false;

  # Networking
  networking.dhcpcd.enable = false;
}
