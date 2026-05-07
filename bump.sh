#!/usr/bin/env bash

set -euo pipefail

for f in flakae/*; do
  pushd "$f" >/dev/null
  echo "bumping $f"
  nix-sync
  popd >/dev/null
done

echo "bumping ."
nix-sync

