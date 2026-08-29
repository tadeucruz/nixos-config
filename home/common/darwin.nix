{
  pkgs,
  username,
  ...
}:
{
  home = {
    sessionVariables = {
      NH_DARWIN_FLAKE = "/Users/${username}/nixos-config";
      SSH_AUTH_SOCK = "/Users/${username}/.bitwarden-ssh-agent.sock";
    };
    packages = with pkgs; [
      obsidian
    ];
  };

  programs.nh = {
    enable = true;
    darwinFlake = "/Users/${username}/nixos-config";
  };

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
          Weekday = 1;
          Hour = 4;
          Minute = 30;
        }
      ];
    };
  };
}
