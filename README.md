# Flakae

A set of project templates for Nix-powered development. Aiming to align with latest best practices in an opinionated way.

This project includes a collection of `flake.nix` templates for projects of different languages. Each playground provides

- `nix develop` for development environment.
- `nix build` for production build and packaging.
- `nix fmt` for code formatting.

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

## Developer Notes

To synchronize nixpkgs to the system version (as in `~/.config/nix/registry.json`):

```console
./bump.sh
```
