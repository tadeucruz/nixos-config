# Shared btrfs mount tuning (citadel + legion). Kept here, not in
# hardware-configuration.nix, since nixos-generate-config overwrites that file.
{ ... }:
{
  fileSystems."/".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];
  fileSystems."/home".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];
  fileSystems."/nix".options = [ "compress=zstd" "noatime" "space_cache=v2" "discard=async" ];

  services.fstrim.enable = true;
}
