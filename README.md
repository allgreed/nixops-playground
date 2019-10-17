# Nixops playground

## Prerequisites
- [nix](https://nixos.org/nix/manual/#chap-installation)
- direnv (`nix-env -i direnv`)

Hint: if something doesn't work because of missing package please add the package to `default.nix` instead of installing on your computer. Why solve the problem for one if you can solve the problem for all? ;)

## Setup
```
direnv allow .
```

## Development
```
make help
```

## Potentially confusing
- external routing and load-balancing is done via Fabio - hence the weird Consul tags on services <- TODO: link to relevant configuration
