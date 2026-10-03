# Wake-on-LAN magic packet sender (omega). `wol <mac>` is generic; per-host
# wrappers hardcode each machine's MAC.
{
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.wakeonlan
    (pkgs.writeShellScriptBin "wake-citadel" ''
      exec ${pkgs.wakeonlan}/bin/wakeonlan 9c:6b:00:52:64:7a
    '')
  ];
}
