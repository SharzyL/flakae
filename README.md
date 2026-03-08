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

## Git Hooks Example

Pre-commit hook that performs format checks

```bash
#!/usr/bin/env bash

set -euo pipefail

nix fmt -- --fail-on-change
```

Pre-commit hook that performs flake checks

```bash
#!/usr/bin/env bash

set -euo pipefail

nix flake check
```

## GitHub CI Workflow Example

```yaml
name: Nix Flake Check

on:
  push:
    branches: [ goshujin ]
  pull_request:
    branches: [ goshujin ]

jobs:
  nix-build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v5

      - name: Install Nix
        uses: cachix/install-nix-action@v31

      - name: Check Nix flake
        run: |
          nix build
          nix flake check
```

## Direnv Example

```bash
use flake
watch_file pkg.nix
PATH_add $(nix build --no-link --print-out-paths nixpkgs#pnpm)/bin
PATH_add $(nix build --no-link --print-out-paths nixpkgs#nodejs)/bin
```
