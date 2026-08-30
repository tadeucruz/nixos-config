{ ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "server string" = "omega NAS";
        "workgroup" = "WORKGROUP";
        "security" = "user";
        "map to guest" = "Bad User";
        "server min protocol" = "SMB2";
        "hosts allow" = "127.0.0.1 192.168.0.0/16";
      };

      media = {
        path = "/mnt/data/Media";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "tadeucruz";
      };

      public = {
        path = "/mnt/data/Public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
      };
    };
  };

  services.avahi.extraServiceFiles = {
    smb = ''
      <?xml version="1.0" standalone='no'?>
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name replace-wildcards="yes">%h</name>
        <service>
          <type>_smb._tcp</type>
          <port>445</port>
        </service>
        <service>
          <type>_device-info._tcp</type>
          <port>0</port>
          <txt-record>model=Macmini8,1</txt-record>
        </service>
      </service-group>
    '';
  };
}
