{
  description = "cpp cmake playground";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }@inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        rec {
          legacyPackages = pkgs;

          defaultPackage = pkgs.stdenv.mkDerivation {
            name = "cpp_cmake";
            nativeBuildInputs = with pkgs; [ cmake ninja ];
            buildInputs = with pkgs; [
              spdlog
              fmt
            ];
            src = with pkgs.lib.fileset; toSource {
              root = ./.;
              fileset = fileFilter
                (
                  file: ! (pkgs.lib.elem file.name [ "flake.nix" "flake.lock" ])
                ) ./.;
            };
          };

          devShell = defaultPackage.overrideAttrs (oldAttrs: {
            # https://github.com/NixOS/nixpkgs/issues/214945
            nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ (with pkgs; [
              clang-tools
            ]);

            # make ninja output colorful
            shellHook = ''
              export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -fdiagnostics-color=always"
            '';
          });
        }
      )
    // {
      inherit inputs; # for easier introspection via nix repl
    };
}
