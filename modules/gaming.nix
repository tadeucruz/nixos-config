# Shared gaming stack (citadel + prothean + legion). Gamescope/session integration
# is handled separately by Jovian on citadel and legion; this covers the
# generic Steam features useful everywhere.
{ lib, pkgs, ... }:
{
  hardware = {
    steam-hardware.enable = true;
    xpadneo.enable = true;
  };

  programs = {
    gamemode.enable = true;

    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
    };
  };

  # scx_lavd (sched-ext game scheduler) on all three hosts. On citadel/legion
  # Jovian forces systemd.services.scx.wantedBy = [] (mkForce, priority 50)
  # because steamos-manager is the supposed owner — but it never actually starts
  # it (verified: sched_ext stayed disabled during a game on legion). Make the
  # boot service authoritative everywhere via mkOverride 0 (beats mkForce).
  # package/scheduler use mkDefault so Jovian's plain definitions (priority 100)
  # win on citadel/legion without a "unique option defined twice" conflict.
  services.scx = {
    enable = true;
    package = lib.mkDefault pkgs.scx.rustscheds;
    scheduler = lib.mkDefault "scx_lavd";
  };

  systemd.services.scx.wantedBy = lib.mkOverride 0 [ "multi-user.target" ];
}
