# Placeholder — regenerate on the machine with `nixos-generate-config`.
# The dummy root filesystem below only exists so the config evaluates in CI;
# replace the whole file on the real hardware.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-ME";
    fsType = "ext4";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
