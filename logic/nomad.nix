{ config, pkgs, nodes, name, ... }:
let
  getCurrentPublicIPv4Address = nodes: currentNode: with builtins; (getAttr currentNode nodes).config.networking.publicIPv4;
  nomadCommonConfig = ''
    log_level = "DEBUG"
    data_dir = "/var/nomad"'';

  nomadServerConfig = {
    filename = "nomad-server.hcl";
    text = ''
      server {
          enabled = true
          bootstrap_expect = ${with builtins; toString (length (attrNames nodes))} // TODO: add support for non-Nomad nodes
      }

      advertise {
        http = "${getCurrentPublicIPv4Address nodes name}"
        rpc  = "${getCurrentPublicIPv4Address nodes name}"
        serf = "${getCurrentPublicIPv4Address nodes name}"
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
      # TODO: Nomad user
      #User = user;
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

  user = "nomad";

  nomadConfigEntry = config: {
    "${config.filename}" = {
      text = config.text;

      inherit user;
      #mode = "0440";
      mode = "0444";
    };
  };
  
  nomadServer = "server";
  nomadClient = "client";

  whichPkg = pkg: "${builtins.getAttr pkg pkgs}/bin/${pkg}";
in
{
  environment.systemPackages = with pkgs; [
    nomad
  ];

  # TODO: why this is not respected? o.0
  #users.users.nomad = {
  #    isSystemUser = true;
  #    group = "";
  #    #extraGroups = [ "docker" ];
  #};

  environment.etc = 
    nomadConfigEntry nomadServerConfig //
    nomadConfigEntry nomadClientConfig
    ;

  systemd.services.nomad-client = nomadService nomadClient;
  systemd.services.nomad-server = nomadService nomadServer;

  networking.firewall.allowedTCPPorts = [
    # TODO: nomad ports
  ];
}
