{ config, pkgs, ... }: 
let
  whichPkg = pkg: "${builtins.getAttr pkg pkgs}/bin/${pkg}";
in
{
  imports = [
    ./nomad.nix
  ];

  environment.systemPackages = with pkgs; [
      consul
      vimHugeX
  ];

  # TODO: make consul cluster work - disable Nomad clustering for the time being

  # TODO: ops accounts (from seperate file)
  # TODO: add ssh banner
  # TODO: secure ssh

  # TODO: shared FS across nodes - full replication

  # TODO: ensure machines won't go to sleep after closing lid
  # TODO: add management scripts from Squire

  # TODO: copy apps configs (how about stically through etc? :D)
  # TODO: copy job descriptions
  # TODO: tune them so that they work
  # TODO: move ephemeral data

  virtualisation.docker.enable = true;

  users.mutableUsers = false;

  # TODO: Move it into a real service without --dev
  # TODO: how about containers and using system stuff? ;D
  systemd.services.consul-dev = {
      description = "Consul client and server";

      serviceConfig = {
         ExecStart = "${whichPkg "consul"} agent --dev --ui";
         Restart = "on-failure";
      };

      wantedBy = [ "multi-user.target" ];
  };

  networking.firewall.allowedTCPPorts = [
    # TODO: consul ports, services ports
  ];
  # TODO: what about UDP ports?
  networking.firewall.enable = false; # TODO: scurity, heh xD
}
