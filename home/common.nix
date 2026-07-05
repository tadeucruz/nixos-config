# Shared Home Manager config across all 3 machines.
{ config, pkgs, lib, username, ... }:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false;

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.user.name  = "Tadeu Cruz";
    settings.user.email = "tadeucruz@gmail.com";
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -alh";
      # rebuild the current machine from the repo root:
      rebuild = "sudo nixos-rebuild switch --flake .#$(hostname)";
      update  = "nix flake update && sudo nixos-rebuild switch --flake .#$(hostname)";
    };
  };

  programs.starship.enable = true;

  programs.firefox = {
    enable = true;

    policies = {
      AppAutoUpdate   = false;
      BackgroundAppUpdate = false;
      DisableTelemetry = true;
      DisablePocket    = true;
      OfferToSaveLogins = false;

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url       = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          updates_disabled  = true;
        };
      };
    };

    profiles.tadeucruz.search = {
      force          = true;
      default        = "ddg";
      privateDefault = "ddg";

      engines = {
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              { name = "channel"; value = "unstable"; }
              { name = "query";   value = "{searchTerms}"; }
            ];
          }];
          icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };

        "NixOS Options" = {
          urls = [{
            template = "https://search.nixos.org/options";
            params = [
              { name = "channel"; value = "unstable"; }
              { name = "query";   value = "{searchTerms}"; }
            ];
          }];
          icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@no" ];
        };

        "NixOS Wiki" = {
          urls = [{
            template = "https://wiki.nixos.org/w/index.php";
            params = [
              { name = "search"; value = "{searchTerms}"; }
            ];
          }];
          icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@nw" ];
        };
      };
    };
  };

  home.packages = with pkgs; [
    btop
  ];
}
