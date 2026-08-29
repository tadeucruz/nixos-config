# Cross-platform Home Manager base settings (stateVersion, user, etc).
{ username, ... }:
{
  home = {
    enableNixpkgsReleaseCheck = false;
    stateVersion = "26.05";
    inherit username;
  };
}
