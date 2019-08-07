{ config, pkgs, nodes, ... }: 
let
  whichPkg = pkg: "${builtins.getAttr pkg pkgs }/bin/${pkg}";
in
{
    # TODO: how to start thoose services automatically?
    # https://github.com/NixOS/nixops/pull/1078
    # systemctl isolate multi-user.target

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

          consul {
            address = "ajpik:8500"
          }

          client {
              enabled = true
          }

          servers = [
            "ajpik:4647"
          ]

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

          bind_addr = "{{ GetPublicIP }}"

          consul {
            address = "{{ GetPublicIP }}:8500"
          }

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

    systemd.services.nomad-client = {
        description = "Nomad client";

        # TODO: Nomad user
        # TODO: how to do UI
        serviceConfig = {
           ExecStart = "${whichPkg "nomad"} agent --config /etc/nomad-client.hcl";
           Restart = "on-failure";
        };

        wantedBy = [ "multi-user.target" ];
    };

    systemd.services.nomad-server = {
        description = "Nomad server";

        # TODO: Nomad user
        # TODO: how to do UI
        serviceConfig = {
           ExecStart = "${whichPkg "nomad"} agent --config /etc/nomad-server.hcl";
           Restart = "on-failure";
        };

        wantedBy = [ "multi-user.target" ];
    };

    systemd.services.consul-dev = {
        description = "Consul client and server";

        serviceConfig = {
           ExecStart = "${whichPkg "consul"} agent --dev --ui --bind '{{ GetPublicIP }}' --client '{{ GetPublicIP }}'";
           Restart = "on-failure";
        };

        wantedBy = [ "multi-user.target" ];
    };

    #networking.firewall.allowedTCPPorts = [ 80 ];
    networking.firewall.enable = false; # TODO: scurity, heh xD
}

