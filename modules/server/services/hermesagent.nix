# HermesAgent LXC container (omega). LXC rootfs is imperative (unlike NixOS
# containers): created once on first boot via the Debian trixie download
# template, then autostarted by lxc.service on every boot. The container
# config is declarative (written from this repo). Requires the generic LXC
# module (modules/server/lxc.nix).
{
  config,
  pkgs,
  ...
}:
let
  hermesagentConfig = pkgs.writeText "hermesagent-lxc-config" ''
    lxc.uts.name = hermesagent
    lxc.arch = amd64
    lxc.rootfs.path = dir:/var/lib/lxc/hermesagent/rootfs
    lxc.net.0.type = veth
    lxc.net.0.link = lxcbr0
    lxc.net.0.flags = up
    lxc.start.auto = 1
  '';
in
{
  assertions = [
    {
      assertion = config.virtualisation.lxc.enable;
      message = "services/hermesagent.nix requires modules/server/lxc.nix (virtualisation.lxc.enable)";
    }
  ];

  systemd.services.hermesagent-lxc = {
    description = "Create HermesAgent LXC container on first boot";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "lxc-net.service"
    ];
    wants = [ "network-online.target" ];
    requires = [ "lxc-net.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 30;
    };
    script = ''
      if [ ! -d /var/lib/lxc/hermesagent ]; then
        ${pkgs.lxc}/bin/lxc-create -n hermesagent -t download -- -d debian -r trixie -a amd64
        cp ${hermesagentConfig} /var/lib/lxc/hermesagent/config
      fi
      ${pkgs.lxc}/bin/lxc-start -n hermesagent || true
    '';
  };
}
