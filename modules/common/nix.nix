{
  username,
  ...
}:
{
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
    flake = "/home/${username}/nixos-config";
  };
}
