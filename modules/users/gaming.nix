{
  username,
  ...
}:
{
  users.users.${username}.extraGroups = [
    "audio"
    "gamemode"
    "i2c"
    "input"
    "networkmanager"
    "uinput"
    "video"
    "wheel"
  ];
}
