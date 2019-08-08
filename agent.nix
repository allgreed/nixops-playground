{ config, pkgs, nodes, ... }: 
let
  whichPkg = pkg: "${builtins.getAttr pkg pkgs}/bin/${pkg}";

  nomadUser = "nomad";
  nomadService = kind: {
        description = "Nomad ${kind}";

        serviceConfig = {
           ExecStart = "${whichPkg "nomad"} agent --config /etc/nomad-${kind}.hcl";
           Restart = "on-failure";
           # TODO: Nomad user
           # TODO: how to do UI
        };

        #ExecReload=/bin/kill -HUP $MAINPID
        #KillMode=process
        #Restart=on-failure
        #RestartSec=42s

        wantedBy = [ "multi-user.target" ];
        #Wants=basic.target
        #After=basic.target network.target
  };

in
{
    environment.systemPackages = with pkgs; [
        nomad
        consul
        vimHugeX
    ];

    virtualisation.docker.enable = true;

    environment.etc = {
      "nomad-client.hcl" = {
        text = ''
          log_level = "DEBUG"
          data_dir = "/var/nomad"

          client {
              enabled = true
          }

          ports {
              http = 5656
          }
        '';

        mode = "0440";
      };

      "nomad-server.hcl" = {
        text = ''
          log_level = "DEBUG"
          data_dir = "/var/nomad"

          server_join {
              retry_join = [
              ]
          }

          server {
              enabled = true
              bootstrap_expect = 1
          }
        '';

        mode = "0440";
      };
    };

    systemd.services.nomad-client = nomadService "client";
    systemd.services.nomad-server = nomadService "server";

    systemd.services.consul-dev = {
        description = "Consul client and server";

        serviceConfig = {
           ExecStart = "${whichPkg "consul"} agent --dev --ui";
           Restart = "on-failure";
        };

        wantedBy = [ "multi-user.target" ];
    };

    #networking.firewall.allowedTCPPorts = [ 80 ];
    networking.firewall.enable = false; # TODO: scurity, heh xD
}

