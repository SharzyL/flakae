#!/usr/bin/env bash

set -e

for f in *; do
  if [ -f "$f"/flake.nix ]; then
    echo
    echo "checking ./$f"
    nix flake check ./"$f"
  fi
done

echo
echo "checking ."
nix flake check
