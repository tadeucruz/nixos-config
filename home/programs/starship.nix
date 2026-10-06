{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = true;
      command_timeout = 2000;
      format = "╭─$username$hostname$directory$git_branch$git_status$golang$nodejs$java$dart$cmd_duration$jobs$line_break╰─$character";

      os = {
        disabled = true;
      };

      username = {
        show_always = true;
        style_user = "bold yellow";
        style_root = "bold red";
        format = "[$user]($style) ";
      };

      hostname = {
        disabled = false;
        ssh_only = false;
        style = "bold green";
        format = "[@$hostname](bold green) ";
      };

      directory = {
        truncation_length = 4;
        truncation_symbol = "…/";
        read_only = "🔒";
        style = "bold cyan";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
      };
      git_status = {
        style = "bold red";
      };

      golang = {
        symbol = " ";
      };
      nodejs = {
        symbol = " ";
      };
      java = {
        symbol = " ";
      };
      dart = {
        symbol = " ";
      };

      cmd_duration = {
        min_time = 2000;
        format = "took [$duration](bold yellow) ";
      };
      jobs = {
        symbol = "✦ ";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };
    };
  };
}
