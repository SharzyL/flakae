#!/usr/bin/env bash

set -e

echo
echo "checking ."
nix build
nix flake check

for f in *; do
  if [ -f "$f"/flake.nix ]; then
    echo
    echo "checking ./$f"
    pushd "$f" >/dev/null
    nix flake check

    if [[ "$f" = "lean" || "$f" = "typst" || "$f" = "adhoc" || "$f" = *lib* ]]; then
      echo "skip running for $f"
      nix build
    elif [[ "$f" = cuda* ]]; then
      if [ -f /run/opengl-driver/lib/libcuda.so ]; then
        nix run
      else
        echo "skip running for cuda project without cuda driver"
        nix build
      fi
    else
      nix run
    fi

    popd >/dev/null
  fi
done

