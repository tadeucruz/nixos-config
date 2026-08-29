{
  username,
  ...
}:
{
  users.users.${username}.extraGroups = [ "wheel" ];

  users.groups.media.members = [ username ];
}
