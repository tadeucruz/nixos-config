{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Tadeu Cruz";
        email = "tadeucruz@gmail.com";
      };
      pull.rebase = true;
    };
  };
}
