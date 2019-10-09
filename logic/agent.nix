{ config, pkgs, nodes, ... }:
let
  whichPkg = pkg: "${builtins.getAttr pkg pkgs}/bin/${pkg}";
  anyPublicIP = nodes: with builtins; (elemAt (attrValues nodes) 1).config.networking.publicIPv4;
in
{
  imports = [
    ./nomad.nix
  ];

  environment.systemPackages = with pkgs; [
      consul
      vimHugeX
  ];

  # TODO: ops accounts (from seperate file)
  # TODO: add direnv + default.nix

  # TODO: move gluster mounts into nixos
  # TODO: ensure machines won't go to sleep after closing lid

  # TODO: bring cluster-zwei online

  # TODO: extract Consul
  # TODO: add ssh banner
  # TODO: secure ssh (will it break nixops?)

  # TODO: add management scripts from Squire vs. make sure they're not needed
  # TODO: backups!

  # TODO: copy apps configs (how about stically through etc? :D)
  # TODO: copy job descriptions
  # TODO: tune them so that they work
  
  # TODO: move persistent data

  # TODO: setup distributed DB
  # TODO: do better security XD
  # TODO: change generic DNS to OpenNic
    # add explicit users and minimum privilages everywhere
    # firewall - is doing firewall worth it in this case?

  virtualisation.docker.enable = true;
  users.mutableUsers = false;
  networking.firewall.enable = false;

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    alwaysKeepRunning = true;

    servers = [
      "8.8.8.8"
      "/consul/127.0.0.1#8600"
    ];

    extraConfig = ''
      cache-size=0
      no-resolv
    '';
  };

  services.glusterfs.enable = true;

  # TODO: Move it into a real service without --dev
  # TODO: how about containers and using system stuff? ;D
  systemd.services.consul-dev = {
      description = "Consul client and server";

      serviceConfig = {
         ExecStart = "${whichPkg "consul"} agent --dev --ui --bind '{{ GetPublicIP }}' --retry-join '${anyPublicIP nodes}'";
         Restart = "on-failure";
      };

      wantedBy = [ "multi-user.target" ];
  };
}
