let
    agent = import ./logic/agent.nix;
    smallDroplet = import ./phy/droplet.nix;
in
{
    resources.sshKeyPairs.ssh-key = {};

    # TODO: pretify it
    maszyna0 = { config, pkgs, nodes, ... }: agent { inherit config; inherit pkgs; inherit nodes;}
      // smallDroplet { inherit config; inherit pkgs; inherit nodes;};

    maszyna1 = { config, pkgs, nodes, ... }: agent { inherit config; inherit pkgs; inherit nodes;}
      // smallDroplet { inherit config; inherit pkgs; inherit nodes;};

    maszyna2 = { config, pkgs, nodes, ... }: agent { inherit config; inherit pkgs; inherit nodes;}
      // smallDroplet { inherit config; inherit pkgs; inherit nodes;};
}
