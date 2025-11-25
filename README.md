# Flakae

Aiming to provide best practices for developing with Nix.

This project includes a collection of minimum `flake.nix` templates for projects of different languages. Each playground provides

- `nix develop` for development environment.
- `nix build` for production build and packaging.
- `nix fmt` for code formatting

Recommended to be used with [direnv](https://github.com/direnv/direnv/) and [nix-direnv](https://github.com/nix-community/nix-direnv/).

## Usage

```console
$ nix flake init --template github:SharzyL/flakae#cpp_cmake
```

or

```console
$ nix flake new --template github:SharzyL/flakae#cpp_cmake ./cpp_cmake
```

Replace `cpp_cmake` with the desired template name, which is a directory name in this project root.

To manually synchronize nixpkgs to the system version:

```console
nix flake update --override-flake nixpkgs github:NixOS/nixpkgs/$(jq < ~/.config/nix/registry.json '.flakes | map(select(.from.id == "nixpkgs")) | .[0].to.rev' -r)
```
