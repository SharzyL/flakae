#!/usr/bin/env bash

set -euo pipefail

nixpkgs_rev=$(jq < ~/.config/nix/registry.json '.flakes | map(select(.from.id == "nixpkgs")) | .[0].to.rev' -r)

for f in *; do
  if [ -f "$f"/flake.nix ]; then
    pushd "$f" >/dev/null
    nix flake update --override-flake nixpkgs github:NixOS/nixpkgs/"$nixpkgs_rev"
    popd >/dev/null
  fi
done

nix flake update --override-flake nixpkgs github:NixOS/nixpkgs/"$nixpkgs_rev"

