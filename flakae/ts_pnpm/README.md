# ts_pnpm

After changing dependencies, regenerate `pnpm-lock.yaml` with `pnpm install`,
then update `pnpmDeps.hash` in `flake.nix` (set it to `""`, run `nix build`,
and copy the hash from the error message).
