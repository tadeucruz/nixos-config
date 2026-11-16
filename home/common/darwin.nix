{
  pkgs,
  username,
  ...
}:
{
  home = {
    # nix-darwin injects `mas` only inside its own brew bundle call; the
    # `rebuild` alias needs it on PATH to upgrade masApps.
    packages = [ pkgs.mas ];

    sessionVariables = {
      NH_DARWIN_FLAKE = "/Users/${username}/nixos-config";
      SSH_AUTH_SOCK = "/Users/${username}/.bitwarden-ssh-agent.sock";
    };
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
