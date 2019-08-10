let
    agent = import ./log/agent.nix;
    smallDroplet = import ./phy/droplet.nix;
in
{
    resources.sshKeyPairs.ssh-key = {};

    maszyna = { config, pkgs, ... }: agent { inherit config; inherit pkgs; }
      // smallDroplet { inherit config; inherit pkgs; };
}
