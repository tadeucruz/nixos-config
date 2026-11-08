{ username, ... }:
{
  # Never sleep, regardless of power source (stays reachable over Tailscale, etc.).
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDockMode = "ignore";
    IdleAction = "ignore";
  };

  # PowerDevil: no auto-suspend in any profile; lid only turns the screen off.
  home-manager.users.${username}.programs.plasma.powerdevil =
    let
      stayAwake = {
        autoSuspend.action = "nothing";
        whenLaptopLidClosed = "turnOffScreen";
        inhibitLidActionWhenExternalMonitorConnected = true;
      };
    in
    {
      AC = stayAwake;
      battery = stayAwake;
      lowBattery = stayAwake;
    };
}
