{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cpu;
    host = "0.0.0.0";
    openFirewall = true;
    loadModels = [
      "deepseek-r1:14b"
      "nomic-embed-text"
    ];
  };

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 3000;
    openFirewall = true;
    environment = {
      RAG_EMBEDDING_ENGINE = "ollama";
      RAG_EMBEDDING_MODEL = "nomic-embed-text";
    };
  };
}
