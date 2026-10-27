# Unsloth Desktop — local app to run and train models (LLMs, MLX, GGUF,
# diffusion, audio). Linux only: upstream ships a `.deb` (Ubuntu/Debian) and an
# AppImage; NixOS can't install the `.deb`, so the AppImage is wrapped via
# appimageTools (FHS env, no FUSE needed). The AppImage bundles its own
# WebKitGTK/GTK stack, so no extraPkgs are required.
#
# macOS gets the same native app through the Homebrew cask instead
# (homebrew/normandy.nix) — that's the nixpkgs-unsupported fallback path.
#
# Pinned by hand: bump `version` (upstream tag without the leading `v`) and
# re-fetch `hash` from the unslothai/unsloth GitHub release.
{ pkgs, ... }:
let
  pname = "unsloth-desktop";
  version = "0.1.911-beta";

  src = pkgs.fetchurl {
    url = "https://github.com/unslothai/unsloth/releases/download/v${version}/Unsloth-Desktop-Linux.AppImage";
    hash = "sha256-+cnQDzwp2pdwHIPyiAI+BujfGp1DcRmVHGhMT1SA/ds=";
  };

  # wrapType2 exposes $out/bin/unsloth-desktop. The env var works around the
  # blank-window Tauri/WebKitGTK bug on NVIDIA (prothean's dGPU, and the usual
  # culprit on Wayland/Mesa stacks).
  unsloth-desktop = pkgs.writeShellScriptBin "unsloth-desktop" ''
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
    exec ${pkgs.appimageTools.wrapType2 { inherit pname version src; }}/bin/unsloth-desktop "$@"
  '';
in
{
  home.packages = [ unsloth-desktop ];

  xdg.desktopEntries.unsloth-desktop = {
    name = "Unsloth Desktop";
    comment = "Run and train models locally (LLM, MLX, GGUF, diffusion, audio)";
    exec = "${unsloth-desktop}/bin/unsloth-desktop %U";
    terminal = false;
    categories = [
      "Development"
      "Science"
      "Utility"
    ];
  };
}
