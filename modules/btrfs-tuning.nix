# Shared btrfs mount tuning (citadel + legion). Kept here, not in
# hardware-configuration.nix, since nixos-generate-config overwrites that file.
{ ... }:
{
  fileSystems = {
    "/".options = [
      "compress=zstd"
      "discard=async"
      "noatime"
      "space_cache=v2"
    ];
    "/home".options = [
      "compress=zstd"
      "discard=async"
      "noatime"
      "space_cache=v2"
    ];
    "/nix".options = [
      "compress=zstd"
      "discard=async"
      "noatime"
      "space_cache=v2"
    ];
  };

  services.fstrim.enable = true;
}
