let
  smallDroplet = import ./droplet.nix;
in
{
    resources.sshKeyPairs.ssh-key = {};

    maszyna = smallDroplet;
}
