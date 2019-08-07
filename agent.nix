{ config, pkgs, ... }: 
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

    systemd.services.nomad-dev = {
        description = "Nomad client and server";

        # TODO: Nomad user
        # TODO: how to do UI
        serviceConfig = {
           ExecStart = "${whichPkg "nomad"} agent --dev --bind '{{ GetPublicIP }}' --client '{{ GetPublicIP }}'";
           Restart = "on-failure";
        };

        wantedBy = [ "default.target" ];
    };

    systemd.services.consul-dev = {
        description = "Consul client and server";

        serviceConfig = {
           ExecStart = "${whichPkg "consul"} agent --dev --ui --bind '{{ GetPublicIP }}' --client '{{ GetPublicIP }}'";
           Restart = "on-failure";
        };

        wantedBy = [ "default.target" ];
    };

    #networking.firewall.allowedTCPPorts = [ 80 ];
    networking.firewall.enable = false; # TODO: scurity, heh xD
}

