{ config, pkgs, ... }: {
    deployment = {
        targetEnv = "digitalOcean";

        digitalOcean = {
            enableIpv6 = true;
            region = "fra1";
            size = "s-1vcpu-1gb";
        };
    };
}
