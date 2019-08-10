{ config, pkgs, ... }: 
let
  whichPkg = pkg: "${builtins.getAttr pkg pkgs}/bin/${pkg}";

  nomadUser = "nomad";
  nomadService = kind: {
     description = "Nomad ${kind}";
     # TODO: how to do UI

     path = with pkgs; [
       iproute
     ];

     serviceConfig = {
       # TODO: Nomad user
       #User = nomadUser;
       # TODO: Nomad group as well ? o.0
       #Group ={{ nomad_group }}

       ExecStart = "${whichPkg "nomad"} agent --config /etc/nomad-${kind}.hcl";
       ExecReload = "/run/current-system/sw/bin/kill -HUP $MAINPID";

       KillMode="process";
       Restart = "on-failure";
       RestartSec="42s";
     };

     wantedBy = [ "multi-user.target" ];
     wants = [ "basic.target" ];
     after = [ "basic.target" "network.target" ];
  };

  nomadCommonConfiguration = ''
      log_level = "DEBUG"
      data_dir = "/var/nomad"'';

  nomadServerConfiguration = {
      filename = "nomad-server.hcl";
      text = ''
          server {
              enabled = true
              bootstrap_expect = 1
          }

          server_join {
              retry_join = [
              ]
          }

          ${nomadCommonConfiguration}'';
  };

  nomadClientConfiguration = {
      filename = "nomad-client.hcl";
      text = ''
          client {
              enabled = true
          }

          ports {
              http = 5656
          }

          ${nomadCommonConfiguration}'';
  };
in
{
    environment.systemPackages = with pkgs; [
        nomad
        consul
        vimHugeX
    ];

    virtualisation.docker.enable = true;

    # TODO: why this is not respected? o.0
    #users.mutableUsers = false;

    #users.users.nomad = {
    #    isSystemUser = true;
    #    group = "";
    #    #extraGroups = [ "docker" ];
    #};

    environment.etc = {
      "${nomadServerConfiguration.filename}" = {
        text = nomadServerConfiguration.text;
        user = nomadUser;
        #mode = "0440";
        mode = "0444";
      };

      "${nomadClientConfiguration.filename}" = {
        text = nomadClientConfiguration.text;
        user = nomadUser;
        #mode = "0440";
        mode = "0444";
      };
    };

    systemd.services.nomad-client = nomadService "client";
    systemd.services.nomad-server = nomadService "server";

    # TODO: Move it into a real service without --dev
    systemd.services.consul-dev = {
        description = "Consul client and server";

        serviceConfig = {
           ExecStart = "${whichPkg "consul"} agent --dev --ui";
           Restart = "on-failure";
        };

        wantedBy = [ "multi-user.target" ];
    };

    #networking.firewall.allowedTCPPorts = [ # TODO: nomad ports, consul ports, services ports
    #];
    networking.firewall.enable = false; # TODO: scurity, heh xD
}
