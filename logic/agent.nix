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

  # TODO: ensure machines won't go to sleep after closing lid
  # TODO: bring cluster-zwei online

  # TODO: extract Consul
  # TODO: add ssh banner
  # TODO: secure ssh

  # TODO: shared FS across nodes - full replication
  # TODO: add management scripts from Squire
  # TODO: make sure Consul is production grade ;d 
  # TODO: backups!

  # TODO: copy apps configs (how about stically through etc? :D)
  # TODO: copy job descriptions
  # TODO: tune them so that they work
  
  # TODO: move persistent data

  # TODO: setup distributed DB
  # TODO: do better security XD
    # add explicit users and minimum privilages everywhere

  virtualisation.docker.enable = true;
  users.mutableUsers = false;
  networking.firewall.enable = false; # TODO: scurity, heh xD - is doing firewall worth it in this case?

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
