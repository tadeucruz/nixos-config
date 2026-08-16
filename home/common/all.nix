# Shared Home Manager config across all machines (cross-platform).
{
  pkgs,
  username,
  ...
}:
{
  home = {
    enableNixpkgsReleaseCheck = false;
    packages = with pkgs; [
      btop
      curl
      herdr
      vim
      wget
    ];
    stateVersion = "26.05";
    inherit username;
  };

  programs = {
    firefox = {
      enable = true;

      policies = {
        AppAutoUpdate = false;
        BackgroundAppUpdate = false;
        DisableTelemetry = true;
        DisablePocket = true;
        OfferToSaveLogins = false;

        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            updates_disabled = true;
          };
        };
      };

      profiles.${username}.search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";
      };
    };

    git = {
      enable = true;
      settings.user.name = "Tadeu Cruz";
      settings.user.email = "tadeucruz@gmail.com";
      settings.pull.rebase = "true";
    };

    home-manager.enable = true;

    starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = true;
        format = "╭─$os$username$hostname$directory$git_branch$git_status$go$java$dart$cmd_duration$jobs$line_break╰─$character";

        os = { disabled = false; style = "bold blue"; };

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
        git_status = { style = "bold red"; };

        go = { symbol = " "; };
        java = { symbol = " "; };
        dart = { symbol = " "; };

        cmd_duration = {
          min_time = 2000;
          format = "took [$duration](bold yellow) ";
        };
        jobs = { symbol = "✦ "; };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vimcmd_symbol = "[❮](bold green)";
        };
      };
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ll = "ls -alh";
      };
    };
  };
}
