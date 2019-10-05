{ config, pkgs, nodes, name, ... }:
let
  nomadCommonConfig = ''
    log_level = "DEBUG"
    data_dir = "/var/nomad"'';

    nomadServerConfig = {
      filename = "nomad-server.hcl";
      text = ''
        server {
            enabled = true
            bootstrap_expect = ${with builtins; toString (length (attrNames nodes))}
        }

        advertise {
          http = "${thisNodeIP}"
          rpc  = "${thisNodeIP}"
          serf = "${thisNodeIP}"
        }

        ${nomadCommonConfig}'';
    };

  nomadClientConfig = {
    filename = "nomad-client.hcl";
    text = ''
      datacenter = "dc1"

      client {
          enabled = true
      }

      ports {
          http = 5656
      }

      ${nomadCommonConfig}'';
  };

  nomadService = kind: {
    description = "Nomad ${kind}";
    # TODO: how to do UI

    path = with pkgs; [
      iproute
    ];

    serviceConfig = {
      ExecStart = "${whichPkg "nomad"} agent --config /etc/nomad-${kind}.hcl";
      ExecReload = "/run/current-system/sw/bin/kill -HUP $MAINPID";

      KillMode="process";
      Restart = "on-failure";
      RestartSec="42s";
    };

    wantedBy = [ "multi-user.target" ];
    requires = [ "consul-dev.service" ]
      ++ (if kind == "client" then [ "nomad-server.service" ] else [])
    ;
    after = [ "consul-dev.service" ]
      ++ (if kind == "client" then [ "nomad-server.service" ] else [])
    ;
    # TODO: is everything here necessary?
  };

  nomadConfigEntry = config: {
    "${config.filename}" = {
      text = config.text;
      mode = "0444";
    };
  };
  
  nomadServer = "server";
  nomadClient = "client";

  thisNodeIP = with builtins; (getAttr name nodes).config.networking.publicIPv4;
  whichPkg = pkg: "${builtins.getAttr pkg pkgs}/bin/${pkg}";
in
{
  environment.systemPackages = with pkgs; [
    nomad
  ];

  environment.etc = 
    nomadConfigEntry nomadServerConfig //
    nomadConfigEntry nomadClientConfig
    ;

  systemd.services.nomad-client = nomadService nomadClient;
  systemd.services.nomad-server = nomadService nomadServer;
}
