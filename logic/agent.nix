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

  # TODO: pin nixpkgs

  # TODO: extract Consul
  # TODO: measure resource usage without anything running

  # TODO: have sum fun
  # TODO: move gluster mounts into nixos

  # TODO: use traefik instead of fabio
  # TODO: have sum fun

  # TODO: secure ssh (will it break nixops?)

  # TODO: do better security XD
    # go through "security" options on nixos

  # TODO: add vault
  # TODO: have sum fun

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
  # TODO: fix the seccurity
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
