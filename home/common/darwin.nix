# macOS-only Home Manager config.
{ pkgs, username, hostname, ... }:
{
  home = {
    sessionVariables = {
      NH_DARWIN_FLAKE = "/Users/${username}/nixos-config";
      SSH_AUTH_SOCK = "/Users/${username}/.bitwarden-ssh-agent.sock";
    };
    packages = with pkgs; [
      bitwarden-desktop
      betterdisplay
      obsidian
      rectangle
    ];
  };

  programs = {
    nh = {
      enable = true;
      darwinFlake = "/Users/${username}/nixos-config";
    };
    zsh.shellAliases.rebuild = "cd $NH_DARWIN_FLAKE && git pull && nh darwin switch -H ${hostname} && nh clean all --keep-since 4d --keep 3";
  };

  # programs.nh.clean wires a systemd timer, which macOS doesn't run →
  # same job as a launchd agent instead.
  launchd.agents.nh-clean = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.nh}/bin/nh"
        "clean"
        "all"
        "--keep-since"
        "4d"
        "--keep"
        "3"
      ];
      StartCalendarInterval = [
        {
          Weekday = 1; # Monday, mirroring systemd timer's "weekly" on Linux
          Hour = 4;
          Minute = 30;
        }
      ];
    };
  };
}
