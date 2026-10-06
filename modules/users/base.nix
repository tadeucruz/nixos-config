{
  pkgs,
  username,
  ...
}:
{
  users.users.${username} = {
    description = "Tadeu Cruz";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/cjwPFM4oVlrqYLY5LxeExIc/qPOH+AQzlPMeV+s9l"
    ];
    shell = pkgs.zsh;
  };
}
