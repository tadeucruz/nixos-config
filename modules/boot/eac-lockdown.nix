# EAC Linux v2 requirement #6: kernel lockdown integrity.
#
# `lockdown=integrity` rejects every module whose certificate is not in the
# kernel's built-in keyring. nixpkgs signs modules with kmodigest (one
# deterministic certificate per module) and collects them into `modules.cer`,
# but nothing embeds that file into the booted image. `rebuildImage` runs
# `scripts/insert-sys-cert`, so the boot entry must point at its output.
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
  boot.kernelParams = [ "lockdown=integrity" ];

  system.systemBuilderCommands = lib.mkAfter ''
    if [ ! -s ${modulesDir}/modules.cer ]; then
      echo "EAC lockdown: modules.cer is missing; the rebuilt image would reject every module." >&2
      exit 1
    fi

    ln -sfn ${image}/${kernel.target} $out/kernel
  '';
}
