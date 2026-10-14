{ username, ... }:
{
  # AC-only: never sleep on lid close (stays reachable over Tailscale, etc.).
  # Remove this import to revert to default (sleep on lid close).
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  # AC-only PowerDevil lid action. Battery/lowBattery stay at default (sleep).
  home-manager.users.${username}.programs.plasma.powerdevil = {
    AC.whenLaptopLidClosed = "turnOffScreen";
    AC.inhibitLidActionWhenExternalMonitorConnected = true;
  };
}
