#!/usr/bin/env bash

set -euo pipefail

nixpkgs_rev=$(jq < ~/.config/nix/registry.json '.flakes | map(select(.from.id == "nixpkgs")) | .[0].to.rev' -r)

for f in flakae/*; do
  pushd "$f" >/dev/null
  echo "bumping $f"
  nix flake update --no-warn-dirty --override-flake nixpkgs github:NixOS/nixpkgs/"$nixpkgs_rev"
  popd >/dev/null
done

echo "bumping ."
nix flake update --no-warn-dirty --override-flake nixpkgs github:NixOS/nixpkgs/"$nixpkgs_rev"

