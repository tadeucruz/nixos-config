{ username, ... }:
{
  home = {
    enableNixpkgsReleaseCheck = true;
    stateVersion = "26.05";
    inherit username;
  };
}
