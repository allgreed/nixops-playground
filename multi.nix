let
    agent = import ./log/agent.nix;
    smallDroplet = import ./phy/droplet.nix;
in
{
    resources.sshKeyPairs.ssh-key = {};

    # TODO: pretify it
    maszyna0 = { config, pkgs, nodes, ... }: agent { inherit config; inherit pkgs; inherit nodes;}
      // smallDroplet { inherit config; inherit pkgs; inherit nodes;};

    maszyna3 = { config, pkgs, nodes, ... }: agent { inherit config; inherit pkgs; inherit nodes;}
      // smallDroplet { inherit config; inherit pkgs; inherit nodes;};

    maszyna4 = { config, pkgs, nodes, ... }: agent { inherit config; inherit pkgs; inherit nodes;}
      // smallDroplet { inherit config; inherit pkgs; inherit nodes;};
}
