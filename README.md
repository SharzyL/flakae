# Flakae

A collection of minimum `flake.nix` templates for projects of different languages. Each playground provides both `nix develop` for development environment and `nix build` for production build and packaging.

Suggested to be used with [direnv](https://github.com/direnv/direnv/).

Struggling to keep up to date with latest nixpkgs.

Usage

```console
$ nix flake init --template github:SharzyL/flakae#cpp_cmake
```

or

```console
$ nix flake new --template github:SharzyL/flakae#cpp_cmake ./cpp_cmake
```


Replace `cpp_cmake` with the desired template name, which is a directory name in this project root.


