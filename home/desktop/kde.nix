{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  programs.plasma = {
    enable = true;

    # Incremental: only write what is declared here, leave the rest of the KDE
    # config alone (editable via the GUI). Nothing is reset on login.
    overrideConfig = false;

    # Dark mode as the default.
    workspace.lookAndFeel = "org.kde.breezedark.desktop";

    powerdevil = {
      AC.powerProfile = "balanced";
      battery.powerProfile = "powerSaving";
      lowBattery.powerProfile = "powerSaving";
    };
  };

  home.activation.rebuildKdeSycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental || true
  '';
}
