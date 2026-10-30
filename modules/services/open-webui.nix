# Open-WebUI (omega) — frontend for LLM chat, backed by OpenRouter instead of
# a local LLM backend (llama.cpp). The API key lives outside git in /etc/openrouter/key
# (OPENAI_API_KEY=sk-or-...), loaded via environmentFile; OPENAI_API_BASE_URL
# points everything at the OpenRouter endpoint.
#
# Local backport of NixOS/nixpkgs#580486: fpdf2 (a python dependency of
# open-webui) fails its test_image_with_explicit_dimensions byte-hash
# reference test with Pillow 13 (fixed upstream in fpdf2 2.9.0). Drop this
# overlay once the backport lands in nixos-26.05.
{ ... }:
{
  nixpkgs.overlays = [
    (_: prev: {
      python3Packages = prev.python3Packages // {
        fpdf2 = prev.python3Packages.fpdf2.overrideAttrs (old: {
          disabledTests = (old.disabledTests or [ ]) ++ [ "test_image_with_explicit_dimensions" ];
        });
      };
    })
  ];

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 3000;
    openFirewall = true;
  };
}
