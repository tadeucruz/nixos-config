# Boots a kernel image rebuilt with the kmodigest module certificates
# embedded (via `linuxPackages.rebuildImage`). nixpkgs signs every module
# deterministically and collects the certs in `modules.cer`, but the stock
# image trusts none of them; `lockdown=integrity` therefore rejects every
# module load.
#
# Not imported by default: the image is host-specific, missing from the
# binary cache, and a specialisation pulls it into the toplevel closure, so
# every kernel/module bump would build it locally.
{
  config,
  lib,
  ...
}:
let
  kernel = config.boot.kernelPackages.kernel;
  modulesDir = "${config.system.modulesTree}/lib/modules/${kernel.modDirVersion}";
  image = config.boot.kernelPackages.rebuildImage {
    inherit (kernel) target;
    inherit (config.system) modulesTree;
  };
in
{
  system.systemBuilderCommands = lib.mkAfter ''
    if [ ! -s ${modulesDir}/modules.cer ]; then
      echo "EAC image: modules.cer is missing; the rebuilt image would reject every module." >&2
      exit 1
    fi

    ln -sfn ${image}/${kernel.target} $out/kernel
  '';
}
