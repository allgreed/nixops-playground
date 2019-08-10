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

  # TODO: compile a TODO from squire's ansibles

  virtualisation.docker.enable = true;

  users.mutableUsers = false;

  # TODO: Move it into a real service without --dev
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
