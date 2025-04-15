#!/usr/bin/env bash

set -e

nix flake update

for f in *; do
  if [ -f "$f"/flake.nix ]; then
    nix flake update --flake ./"$f"
  fi
done

