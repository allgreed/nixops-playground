{ config, pkgs, nodes, ... }:
{
  imports = [
    ./nomad.nix
    ./consul.nix
    #./operators.nix
    # TODO: fix the operators
  ];

  environment.systemPackages = with pkgs; [
      vimHugeX
  ];

  # TODO: figure out how to pin nixops to my funny version and document that a DO key in env vars is required

  # TODO: have sum fun - deploy stateful service, shut a designated node for a minute, observe what happens
  # TODO: move gluster mounts into nixos

  # TODO: use traefik instead of fabio
  # TODO: have sum fun - try hooking it up to a domain

  # TODO: do better security XD
    # secure access to Nomad
    # go through "security" options on nixos
  # TODO: have sum fun - use a real DB from DO and register it into Consul 

  # TODO: secure ssh (will it break nixops?)

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

  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d";
  };
}
