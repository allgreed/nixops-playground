{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [
    nixops
    nomad
    git
    gnumake
  ];
}

