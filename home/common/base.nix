{ username, ... }:
{
  home = {
    enableNixpkgsReleaseCheck = true;
    inherit username;
  };
}
