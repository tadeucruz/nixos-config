# Shared kernel for citadel, prothean, and legion: OpenGamingCollective's release
# tree built directly, no vanilla base + patch dance.
#
# The OGC release tag (e.g. v7.2-ogc4) IS the kernel: the vanilla 7.2.0 tree with
# all their patches already applied (handheld drivers, AMD HDMI 2.1 VRR/ALLM, etc.).
# Building the tree directly means there's no monolithic.patch artifact and no
# apply-failure mode — the release tag is the single source of truth.
#
# Deliberately decoupled from nixpkgs's linux_latest: nixpkgs updates freely, the
# kernel only moves when a new OGC release is picked up. Bump via
# scripts/update-ogc-kernel.sh (CI: .github/workflows/check-ogc-update.yml).
{ pkgs, ... }:

let
  ogcRelease = "v7.2-ogc4";

  # Hash is over the unpacked tree (fetchzip semantics); get it with:
  #   nix-prefetch-url --unpack <archive-url>
  ogcSrc = pkgs.fetchzip {
    url = "https://github.com/OpenGamingCollective/linux/archive/refs/tags/${ogcRelease}.tar.gz";
    hash = "sha256-+ilzf1c7enwttOigM76ByekSS+P6D0nwn5L1e8fZYrE=";
  };

  # modDirVersion must match the tree's Makefile (VERSION.PATCHLEVEL.SUBLEVEL).
  # Verified for v7.2-ogc4: 7.2.0.
  ogcKernel = pkgs.buildLinux {
    pname = "linux-ogc";
    version = ogcRelease;
    modDirVersion = "7.2.0";
    src = ogcSrc;
    # nixpkgs's generic kernel patches (bridge STP helper, request_key helper).
    # Stable and branch-agnostic, so they don't couple us to linux_latest's set.
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ];
  };
in
pkgs.linuxPackagesFor ogcKernel