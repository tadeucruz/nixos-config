{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      addresses = true;
      enable = true;
    };
  };
}
