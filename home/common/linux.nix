{
  username,
  ...
}:
{
  home.homeDirectory = "/home/${username}";

  home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock";
}
