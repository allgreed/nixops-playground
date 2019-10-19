{ config, pkgs, nodes, ... }:
let
  whichPkg = pkg: "${builtins.getAttr pkg pkgs}/bin/${pkg}";
  anyPublicIP = nodes: with builtins; (elemAt (attrValues nodes) 1).config.networking.publicIPv4;
in
{
  imports = [
    ./nomad.nix
    ./operators.nix
  ];

  environment.systemPackages = with pkgs; [
      consul
      vimHugeX
  ];

  # TODO: move gluster mounts into nixos
  # TODO: ensure machines won't go to sleep after closing lid
  # TODO: bring cluster-zwei online

  # TODO: extract Consul
  # TODO: add ssh banner
  # TODO: secure ssh (will it break nixops?)
  # TODO: backups!

  # TODO: copy apps configs (how about stically through etc? :D) - Consul
  # TODO: copy job descriptions
  # TODO: tune them so that they work

  # TODO: add management scripts from Squire vs. make sure they're not needed
  # TODO: move persistent data

  # TODO: change generic DNS to OpenNic
  # TODO: do better security XD
    # add explicit users and minimum privilages everywhere
    # firewall - is doing firewall worth it in this case?
    # go through "security" options on nixos

  virtualisation.docker.enable = true;
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

  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false; # at least until I figure out how to securely set passwords across multiple machines

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

  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d";
  };
}
