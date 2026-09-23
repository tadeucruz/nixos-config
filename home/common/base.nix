{ username, ... }:
{
  home = {
    enableNixpkgsReleaseCheck = true;
    stateVersion = "26.11";
    inherit username;
  };
}
