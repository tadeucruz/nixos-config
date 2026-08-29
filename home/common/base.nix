{ username, ... }:
{
  home = {
    enableNixpkgsReleaseCheck = yes;
    stateVersion = "26.05";
    inherit username;
  };
}
