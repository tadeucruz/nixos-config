# GE-Proton (GloriousEggroll) as a Steam compatibility tool. nixpkgs's
# proton-ge-bin lags the fast-moving upstream releases (and GE-Proton11-3 broke
# on icuuc.dll.u_setMemoryFunctions_65, black-screening e.g. Cyberpunk 2077 —
# upstream issue GloriousEggroll/proton-ge-custom#651, fixed in 11-4), so the
# latest release is pinned here. Intended for `programs.steam.extraCompatPackages`
# only. Bump via scripts/update-proton.sh.
{
  lib,
  stdenvNoCC,
  fetchurl,
  # Can be overridden to alter the display name in steam.
  steamDisplayName ? "GE-Proton",
}:
stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    # Real upstream release tag (kept out of `version` so the store path stays
    # `proton-ge-latest`; the hash still changes on bump).
    release = "GE-Proton11-6";
  in
  {
    pname = "proton-ge";
    version = "latest";

    src = fetchurl {
      url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${release}/${release}-x86_64.tar.gz";
      hash = "sha256-ZZ+NcfL3hlk0ASCyDBxaFGSqE4k5MyoTdt6iL20twuQ=";
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
      # Upstream ships GE-Proton11-x tarballs with a top-level
      # GE-Proton11-x-x86_64/ directory since the arch-split releases.
      tar -xf $src -C $steamcompattool --strip-components=1

      runHook postInstall
    '';

    preFixup = ''
      substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
        --replace-fail "${release}-x86_64" "${steamDisplayName}"
    '';

    meta = {
      description = ''
        Compatibility tool for Steam Play based on Wine and additional components.

        (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
      '';
      homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
      license = lib.licenses.bsd3;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  }
)
