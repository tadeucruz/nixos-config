# Gaming profile — composes the gaming program files.
{ ... }:
{
  imports = [
    ./programs/mangohud.nix
    ./programs/steam.nix
  ];
}
