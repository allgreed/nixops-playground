let
  nixpkgs = builtins.fetchGit {
    name = "nixos-unstable-2020-09-11";
    url = "https://github.com/nixos/nixpkgs-channels/";
    ref = "refs/heads/nixos-unstable";
    rev = "61525137fd1002f6f2a5eb0ea27d480713362cd5";
    # obtain via `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`
  };
  pkgs = import nixpkgs { config = {}; };
in

with pkgs;
mkShell {
  buildInputs = [
    nixops
    nomad
    git
    gnumake
  ];
}

