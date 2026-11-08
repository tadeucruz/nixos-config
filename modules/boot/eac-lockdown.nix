# EAC Linux v2 requirement #6: kernel lockdown integrity.
#
# Requires the rebuilt image from `eac-image.nix`: the stock image carries no
# module-signing certificates, so `lockdown=integrity` rejects every module.
{
  imports = [ ./eac-image.nix ];

  boot.kernelParams = [ "lockdown=integrity" ];
}
