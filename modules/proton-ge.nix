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
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-ge";
  version = "GE-Proton11-5";

  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${finalAttrs.version}/${finalAttrs.version}-x86_64.tar.gz";
    hash = "sha256-3kPEsl88BH20m5bETYR1mVLFoBMypogFoJ5p+V3DinU=";
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
      --replace-fail "${finalAttrs.version}-x86_64" "${steamDisplayName}"
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
})
