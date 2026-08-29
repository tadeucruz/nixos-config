# Proton-CachyOS as a Steam compatibility tool. Not in nixpkgs, so packaged here
# (pinned to a release). Intended for `programs.steam.extraCompatPackages` only.
# Bump via scripts/update.sh cachyos. The x86_64 build works on all three hosts;
# a separate x86_64_v3 asset exists upstream for AVX2-only machines if wanted.
{
  lib,
  stdenvNoCC,
  fetchurl,
  # Can be overridden to alter the display name in steam.
  steamDisplayName ? "Proton-CachyOS",
}:
stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    # Real upstream release (kept out of `version` so the store path stays
    # `proton-cachyos-latest`; the hash still changes on bump). The "cachyos-"
    # prefix is part of the release tag only, not of the asset name.
    release = "11.0-20260703-slr";
  in
  {
    pname = "proton-cachyos";
    version = "latest";

    src = fetchurl {
      url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${release}/proton-cachyos-${release}-x86_64.tar.xz";
      hash = "sha256-Yv9LJ1AYByPMAFOGCP5ofiHR2Rox72TOGnyfRsPbMQs=";
    };

    dontConfigure = true;
    dontBuild = true;

    outputs = [
      "out"
      "steamcompattool"
    ];

    installPhase = ''
      runHook preInstall

      # Make it impossible to add to an environment. You should use the appropriate NixOS option.
      echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

      mkdir $steamcompattool
      # Upstream ships the tarball with a top-level proton-cachyos-...-x86_64/
      # directory.
      tar -xf $src -C $steamcompattool --strip-components=1

      runHook postInstall
    '';

    preFixup = ''
      substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
        --replace-fail "proton-cachyos-${release}-x86_64" "${steamDisplayName}"
    '';

    meta = {
      description = ''
        CachyOS custom Proton fork for Steam Play, based on GE-Proton.

        (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
      '';
      homepage = "https://github.com/CachyOS/proton-cachyos";
      license = lib.licenses.bsd3;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  }
)
