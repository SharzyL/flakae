#!/usr/bin/env bash

set -e

for f in *; do
  if [ -f "$f"/flake.nix ]; then
    nix flake update --flake ./"$f"
  fi
done

nix flake update

