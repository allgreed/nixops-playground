{ config, pkgs, ... }: {
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWnwdY4pSLVyuLwMARJ6tQtnxcrQS4dx5RM+HiVBj4HSGWSSGNpbFlwcUx4bDuSII6hofuoPy83OvtKs/n1+SWv9UDue72slXamh2XbTXDtA2IG2XiiaiXSUUbJX5/ejKE+90/OK87ccGpDFgJVAD53EMV6NUJXWbDKwVrAnVEzoCPqGLYGDPs389pzM1OYHFzbuWAh5Wlrv/05j4T8b5fB+QsX87Z8FT0tDwPjUYzsd6ugL7Vf5EU8HkLAH+9m128OMGcOuv5bTVUVbR7CI7c8bmw2+nw7AjgX7oexQFC+fevSKYVRbusZ88jbz5sUhCC58d3mdfmYxME3z/sD37Cr0HTUBOEWS4eP0BqF0w+tTTl3bsXCUhs35cMIoUY8SRuij3zqsGNDqWhVuVFwI5uYJOXEtBfQuI/79inJhLHi/SwnXu1FXJ0q7kRureMR9EnrZ8LEMNZ9rrFwCdhJXIlHzu9vpbMlpbSAkiHmfiigcCZFxyBr/GRRj6srTGxkv63fsOYOVfvTSzUa4cpqxEcD+0Yhyr7mf/OfpdwTaR/r8SPvP3CJUme2pviXP7FxcVYKhHMAJTLQ2xMwEt6yyqs/RR9/lYdQFyCwM5oBZQqZxHJMSqdXp+ZUEFa5orKWvaxBisLQy2tIEqE77h22er3zK0VFK/ETE/3Cxdz3HtlOQ== allgreed@terminator"
    ];

    deployment = {
        targetEnv = "digitalOcean";

        digitalOcean = {
            enableIpv6 = true;
            region = "fra1";
            size = "s-1vcpu-1gb";
        };
    };
}
