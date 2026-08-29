# MangoHud overlay — imported by ../gaming.nix (citadel + prothean + legion).
{ ... }:
{
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;

    settings = {
      horizontal = true;
      position = "top";
    };
  };
}
