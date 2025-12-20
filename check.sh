#!/usr/bin/env bash

set -e

echo
echo "checking ."
if [ ! -v GITHUB_ACTION ]; then
  nix build
fi
nix flake check

for f in *; do
  if [ -f "$f"/flake.nix ]; then
    echo
    echo "checking ./$f"
    pushd "$f" >/dev/null
    nix flake check

    if [[ "$f" = "lean" || "$f" = "typst" || "$f" = "adhoc" || "$f" = *lib* ]]; then
      echo "run nix build for $f"
      nix build
    elif [[ "$f" = cuda* ]]; then
      if [ -v GITHUB_ACTION ]; then
        echo "skip checking cuda on GitHub action since it is too large"
      elif [ -f /run/opengl-driver/lib/libcuda.so ]; then
        echo "run nix run for $f"
        nix run
      else
        echo "run nix build for $f since no cuda driver detected"
        nix build
      fi
    else
      echo "run nix run for $f"
      nix run
    fi

    popd >/dev/null
  fi
done

