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

  # TODO: add direnv + default.nix

  # TODO: ops accounts (from seperate file)
  # TODO: move gluster mounts into nixos
  # TODO: ensure machines won't go to sleep after closing lid
  # TODO: bring cluster-zwei online

  # TODO: extract Consul
  # TODO: add ssh banner
  # TODO: secure ssh (will it break nixops?)

  # TODO: copy apps configs (how about stically through etc? :D) - Consul
  # TODO: copy job descriptions
  # TODO: tune them so that they work
  # TODO: backups!

  # TODO: add management scripts from Squire vs. make sure they're not needed
  # TODO: move persistent data

  # TODO: setup distributed DB
  # TODO: do better security XD
  # TODO: change generic DNS to OpenNic
    # add explicit users and minimum privilages everywhere
    # firewall - is doing firewall worth it in this case?

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
  # TODO: Parametrize with stuff from operators.nix
  users.users.allgreed = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" ];
      openssh.authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWnwdY4pSLVyuLwMARJ6tQtnxcrQS4dx5RM+HiVBj4HSGWSSGNpbFlwcUx4bDuSII6hofuoPy83OvtKs/n1+SWv9UDue72slXamh2XbTXDtA2IG2XiiaiXSUUbJX5/ejKE+90/OK87ccGpDFgJVAD53EMV6NUJXWbDKwVrAnVEzoCPqGLYGDPs389pzM1OYHFzbuWAh5Wlrv/05j4T8b5fB+QsX87Z8FT0tDwPjUYzsd6ugL7Vf5EU8HkLAH+9m128OMGcOuv5bTVUVbR7CI7c8bmw2+nw7AjgX7oexQFC+fevSKYVRbusZ88jbz5sUhCC58d3mdfmYxME3z/sD37Cr0HTUBOEWS4eP0BqF0w+tTTl3bsXCUhs35cMIoUY8SRuij3zqsGNDqWhVuVFwI5uYJOXEtBfQuI/79inJhLHi/SwnXu1FXJ0q7kRureMR9EnrZ8LEMNZ9rrFwCdhJXIlHzu9vpbMlpbSAkiHmfiigcCZFxyBr/GRRj6srTGxkv63fsOYOVfvTSzUa4cpqxEcD+0Yhyr7mf/OfpdwTaR/r8SPvP3CJUme2pviXP7FxcVYKhHMAJTLQ2xMwEt6yyqs/RR9/lYdQFyCwM5oBZQqZxHJMSqdXp+ZUEFa5orKWvaxBisLQy2tIEqE77h22er3zK0VFK/ETE/3Cxdz3HtlOQ== allgreed@terminator"
      ];
      initialHashedPassword = "$6$sEk83.F2VbsYW$iILuEeRZZE5aIh87UIze4R7g82JGavVkm3yURcI38Zka5M/djEClUEr0.PWklwdea0UrGKrNAx3B.BKh435Uu0"; # please change the password via local.nix ASAP
  };

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
