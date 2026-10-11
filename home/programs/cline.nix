# Cline CLI (AI agent) — home-manager has no module for it yet, so package wrapper only.
# Guarded: `cline` is not in nixpkgs-stable (omega) yet — skip instead of failing eval.
{ lib, pkgs, ... }:
{
  home.packages = lib.optional (pkgs ? cline) pkgs.cline;
}
