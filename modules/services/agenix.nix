{ pkgs, username, ... }:
{
  # Single shared key: /etc/age/identity on NixOS, ~/.config/age/keys.txt on
  # Darwin (the launchd daemon runs as root and can read the user's key).
  age.identityPaths =
    if pkgs.stdenv.hostPlatform.isDarwin then
      [ "/Users/${username}/.config/age/keys.txt" ]
    else
      [ "/etc/age/identity" ];

  age.secrets.openroute-token = {
    file = ../../secrets/openroute-token.age;
    owner = username;
    mode = "0400";
  };
}
