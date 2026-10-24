# Shared btrfs mount tuning (all NixOS hosts). Kept here, not in
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

  # Periodic online scrub. The NixOS default already collects every distinct
  # btrfs filesystem (deduped by device), so no per-host list is needed.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };
}
