{
  services.flatpak = {
    enable = true;
    packages = [
      "com.bitwarden.desktop"
      "com.github.tchx84.Flatseal"
      "md.obsidian.Obsidian"
      "net.retrodeck.retrodeck"
    ];
    update = {
      # Update flatpaks on every `nixos-rebuild switch`.
      onActivation = true;
      # Also update periodically in the background, independent of rebuilds.
      auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };
}
